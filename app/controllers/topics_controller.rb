class TopicsController < ApplicationController
  before_action :authenticate_user!, except: :show # ログインしているか調べるヘルパーメソッド, showは例外(except)
  def index
    @topics = Topic.all.includes(:user).where(user_id: current_user.id)
    @entries = Entry.all.includes(:user, :topic)
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new(topic_params) # topic_paramsの値が入ったオブジェクト作成
    image = Magick::ImageList.new('./public/base_image.png') # テキストを書き込むための画像を読み込む
    draw = Magick::Draw.new # 画像に線や文字を描画するDrawオブジェクト生成
    title = cut_text(@topic.title) # cut_textの処理結果を代入
    draw.annotate(image, 0, 0, 0, -120, title) do # 文字の描画(画像、幅、高さ、x座標、y座標、描画する文字)
      self.font = 'app/assets/NotoSansJP-Bold.otf' # 日本語対応可能なフォントにする
      self.fill = '#000' # フォントの塗りつぶし色
      self.gravity = Magick::CenterGravity # 描画基準位置(中央)
      self.font_weight = Magick::BoldWeight # フォントの太さ
      self.stroke = 'transparent' # フォントの縁取り色(透過)
      self.pointsize = 48 # フォントサイズ(48pt)
    end
    image_path = image.write(uniq_file_name).filename # uniq_file_nameメソッドの処理結果のファイル名を代入
    image_url = cut_path(image_path) # cut_textメソッドの処理結果をimage_urlに代入
    @topic.image_url = image_url # @topicに作成画像であるimage_urlを追加
    if @topic.save
      flash[:notice] = "トピックが保存されました"
      redirect_to @topic # Topic.newで作った＠topicへリダイレクト
    else
      flash[:alert] = "募集作成に失敗しました"
    end
  end

  def show
    @topic = Topic.find(params[:id])
    @entries = Entry.where(topic_id: @topic)
  end

  private

    def topic_params # title,contentの受け取りを許可し、mergeでuser_idにcurrentuser.idを追加で受け取る
      params.require(:topic).permit(:title, :content).merge(user_id: current_user.id)
    end

    def cut_path(url) # /./public/以下を""に切り取る
      url.sub(/\.\/public\//, "")
    end

    def uniq_file_name # .public/ランダムな文字列/.pngというファイル名に加工する
      "./public/#{SecureRandom.hex}.png"
    end

    def cut_text(text) # 15文字ごとに改行入れる
      text.scan(/.{1,15}/).join("\n")
    end
end
