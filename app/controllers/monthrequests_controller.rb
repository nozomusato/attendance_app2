class MonthrequestsController < ApplicationController
  before_action :except_admin,    only: :create

  def create
    # monthrequest"=>{"boss_id"=>"2", "req_date"=>"2019-03-01", "user_id"=>"1"}, "commit"=>"申請"}
    # month_params　は{"boss_id"=>"2", "req_date"=>"2019-04-01", "user_id"=>"1"}
    
    month_params = monthrequest_params
    month_params["month_approval"] = '申請中'
    # 申請された月とユーザー探す。なかったら登録。あったら更新
    month_data = Monthrequest
                .where(req_date: month_params[:req_date])
                .where(user_id: user_id_params[:user_id])
                .first
                
    user = User.find(user_id_params[:user_id])
    
    if month_data.blank?
      monthrequest = Monthrequest.new(month_params)
      if monthrequest.save
        flash[:success] = "申請を登録しました。"
        redirect_to user
      else
        flash[:danger] = "登録失敗しました。"
        redirect_to user
      end
    else
      # 再度申請を出されたことになるので申請中に変更
      # month_params["month_approval"] = '申請中'
      if month_data.update_attributes(month_params)
        flash[:success] = "更新しました。"
      else
        flash[:danger] = "更新失敗しました。"
      end
      redirect_to user
    end
  end
  
  private
      # adminのアクセス必要ないページ
    def except_admin
      redirect_to users_url if current_user.admin?
    end
    
    def monthrequest_params
      params.permit(monthrequest: [:boss_id, :req_date, :user_id])[:monthrequest]
    end
    
    def user_id_params
      params.permit(monthrequest: [:user_id])[:monthrequest]
    end
    
end
