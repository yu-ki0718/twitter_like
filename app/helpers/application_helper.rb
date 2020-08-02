module ApplicationHelper

  module ApplicationHelper
    def get_twitter_card_info(post)
      twitter_card = {}
      if post.present?
        if post.id.present?
          twitter_card[:url] = "https://[herokuアプリ名].herokuapp.com/posts/#{post.id}"
          twitter_card[:image] = "https://s3-ap-northeast-1.amazonaws.com/[S3バケット名]/images/#{post.id}.png"
        else
          twitter_card[:url] = 'https://[herokuアプリ名].herokuapp.com/'
          twitter_card[:image] = "https://techpit-market-prod.s3.amazonaws.com/uploads/part_attachment/file/3883/2ce8c3fa-117a-46e2-b308-f7fed69f56c9.png"
        end
      else
        twitter_card[:url] = 'https://[herokuアプリ名].herokuapp.com/'
        twitter_card[:image] = "https://techpit-market-prod.s3.amazonaws.com/uploads/part_attachment/file/5797/9942f27f-bb05-4a0e-bd58-e9d6d462dcdd.png"
      end
      twitter_card[:title] = "タイトル"
      twitter_card[:card] = 'summary_large_image'
      twitter_card[:description] = '説明文'
      twitter_card
    end
  end
  
end
