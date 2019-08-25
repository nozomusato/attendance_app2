class OvertimesController < ApplicationController
  def index
    @user = User.find(params[:user_id])
    @overtimes = Overtime.all
  end

  def new
    @user = User.find(params[:user_id])
    @overtime = Overtime.new # ベースポイントオブジェクトを生成し、インスタンス変数に代入します。
  end
  
  def create
    @user = User.find(params[:user_id])
    @overtime = Overtime.new(overtime_params)
    if @overtime.save
      flash[:success] = '拠点情報を追加しました。'
      redirect_to user_overtimes_path
    else
      render user_overtimes_path
    end
  end
end

private

    def overtime_params
      params.require(:overtime).permit(:note)
    end