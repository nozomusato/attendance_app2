class User < ApplicationRecord
  has_many :attendances, dependent: :destroy
  before_save { self.email = email.downcase }
  validates :name,  presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  validates :affiliation, length: { in: 2..50 }, allow_blank: true
  validates :basic_work_time, presence: true
  validates :designated_work_start_time, presence: true
  validates :designated_work_end_time, presence: true
  
  validates :uid, presence: true, uniqueness: true
  validates :employee_number, presence: true, uniqueness: true, numericality: { only_integer: true }
  
  has_many :attendances, dependent: :destroy
  has_many :monthrequests, dependent: :destroy
  
  # csv import class
  def self.import(file)
    begin
      CSV.foreach(file.path, headers: true) do |row|
        # IDが見つかれば、レコードを呼び出し、見つかれなければ、新しく作成
        @user = find_by(id: row["id"]) || new
        # CSVからデータを取得し、設定する
        @user.attributes = row.to_hash.slice(*updatable_attributes)
        # 保存する
        @user.save
      end
      @user.errors.any? ? msg = "#{@user.errors.count}個のエラー" : msg = "登録完了"
    rescue CSV::MalformedCSVError
      msg = "文字コードUTF-8で登録してください。"
    rescue ActiveRecord::RecordNotUnique
      msg = "重複しているデータがあります。"
    rescue => e
      msg = "#{e.class}"
    end
    
  end
  
  # 更新を許可するカラムを定義
  def self.updatable_attributes
    ["name", "email", "affiliation", "employee_number", "uid", "basic_work_time",
    "designated_work_start_time", "designated_work_end_time", "superior", "admin", "password"]
  end
  
end