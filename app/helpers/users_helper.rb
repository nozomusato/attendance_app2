module UsersHelper
    # 基本時間などの値を、指定の書式にフォーマットして返す
  def format_basic_work_time(datetime)
    format("%.2f", ((datetime.hour * 60) + datetime.min)/60.0)
  end
  
  # User table idから名前入れる
  def u_name(f_id)
    if !f_id.blank?
      User.find(f_id).name
    end
  end
  
  
end
