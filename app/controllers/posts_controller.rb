class PostsController < ApplicationController
  before_action :set_post, only: [:show, :edit, :update, :destroy, :confirm]

  # GET /posts
  # GET /posts.json
  def index
    @posts = Post.all
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
  end

  def confirm
  end

  # POST /posts
  # POST /posts.json
  def create
    # @postに入力したcontent、kindが入っています。（id、pictureはまだ入っていません）
    @post = Post.new(post_params)
    # idとして採番予定の数字を作成（現在作成しているidの次、存在しない場合は1を採番）
    if Post.last.present?
      next_id = Post.last.id + 1
    else
      next_id = 1
    end
    # 画像の生成メソッド呼び出し（画像のファイル名にidを使うため、引数として渡す）
    make_picture(next_id)
    if @post.save
      # 確認画面へリダイレクト
      redirect_to confirm_path(@post)
    else
      render :new
    end
  end

  # PATCH/PUT /posts/1
  # PATCH/PUT /posts/1.json
  def update
    if @post.update(post_params)
      make_picture(@post.id)
      redirect_to confirm_path(@post)
    else
      render :edit
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post.destroy
    respond_to do |format|
      format.html { redirect_to posts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.require(:post).permit(:content, :picture, :kind)
    end

    def make_picture(id)
      sentense = ""
      # 改行を消去
      content = @post.content.gsub(/\r\n|\r|\n/," ")
      # contentの文字数に応じて条件分岐
      if content.length <= 28 then
        # 28文字以下の場合は7文字毎に改行
        n = (content.length / 7).floor + 1
        n.times do |i|
          s_num = i * 7
          f_num = s_num + 6
          range =  Range.new(s_num,f_num)
          sentense += content.slice(range)
          sentense += "\n" if n != i+1
        end
        # 文字サイズの指定
        pointsize = 90
      elsif content.length <= 50 then
        n = (content.length / 10).floor + 1
        n.times do |i|
          s_num = i * 10
          f_num = s_num + 9
          range =  Range.new(s_num,f_num)
          sentense += content.slice(range)
          sentense += "\n" if n != i+1
        end
        pointsize = 60
      else
        n = (content.length / 15).floor + 1
        n.times do |i|
          s_num = i * 15
          f_num = s_num + 14
          range =  Range.new(s_num,f_num)
          sentense += content.slice(range)
          sentense += "\n" if n != i+1
        end
        pointsize = 45
      end
      # 文字色の指定
      color = "white"
      # 文字を入れる場所の調整（0,0を変えると文字の位置が変わります）
      draw = "text 0,0 '#{sentense}'"
      # フォントの指定
      font = ".fonts/GenEiGothicN-U-KL.otf"
      # ↑これらの項目も文字サイズのように背景画像や文字数によって変えることができます
      # 選択された背景画像の設定
      case @post.kind
      when "black" then
        base = "app/assets/images/black.jpg"
      # 今回は選択されていない場合は"red"となるようにしている
      else
        base = "app/assets/images/red.jpg"
      end
      # minimagickを使って選択した画像を開き、作成した文字を指定した条件通りに挿入している
      image = MiniMagick::Image.open(base)
      image.combine_options do |i|
        i.font font
        i.fill color
        i.gravity 'center'
        i.pointsize pointsize
        i.draw draw
      end
      # 保存先のストレージの指定。Amazon S3を指定する。
      storage = Fog::Storage.new(
        provider: 'AWS',
        aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        region: 'ap-northeast-1'
      )
      # 開発環境or本番環境でS3のバケット（フォルダのようなもの）を分ける
      case Rails.env
        when 'production'
          # バケットの指定・URLの設定
          bucket = storage.directories.get('[twitter-like0718]')
          # 保存するディレクトリ、ファイル名の指定（ファイル名は投稿id.pngとしています）
          png_path = 'images/' + id.to_s + '.png'
          image_uri = image.path
          file = bucket.files.create(key: png_path, public: true, body: open(image_uri))
          @post.picture = 'https://s3-ap-northeast-1.amazonaws.com/[twitter-like0718]' + "/" + png_path
        when 'development'
          bucket = storage.directories.get('[twitter-like0718]')
          png_path = 'images/' + id.to_s + '.png'
          image_uri = image.path
          file = bucket.files.create(key: png_path, public: true, body: open(image_uri))
          @post.picture = 'https://s3-ap-northeast-1.amazonaws.com/[twitter-like0718]' + "/" + png_path
      end
    end
end
