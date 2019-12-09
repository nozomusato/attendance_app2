module SessionsHelper
    
    #引数に渡されたユーザーでログインする
    def log_in(user)
        session[:user_id] = user.id
    end
    
    def current_user
     if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
     end
    end
    
    def current_user?(user)
        user == current_user
    end
    
    
    #ユーザーがログインしていればtrue、その他ならfalseを返す
    def logged_in?
     !current_user.nil?
    end
    
    def log_out
    session.delete(:user_id)
    @current_user = nil
    end
    
     # 記憶しているURL (もしくはデフォルト値) にリダイレクトする
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを記憶しておく
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
  
  def make_new_user
    uid_name = User.maximum('employee_number')
    if User.where(uid: "new#{uid_name}").exists?
      uid_name = "new#{tmp}_#{DateTime.now.sec}"
    end
    # 重複防ぐため仮登録では最大値の+1とする
    @ini_uid = "new#{uid_name}"
    @ini_employee_number = User.maximum('employee_number') + 1
  end
end