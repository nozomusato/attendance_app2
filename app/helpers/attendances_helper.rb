module AttendancesHelper
  def current_time
    Time.new(
        # Time.now.year,
        # Time.now.month,
        # Time.now.day,
        2000,1,1,
        Time.now.hour,
        Time.now.min,0
        )
  end
  
  def working_times(started_at, finished_at, nextday)
    # 時間のみ正しいので
    started_at = started_at - started_at.beginning_of_day
    finished_at = finished_at - finished_at.beginning_of_day
    if nextday
      format("%.2f", (((finished_at - started_at + 86400) / 60) / 60.0))
    else
      format("%.2f", (((finished_at - started_at) / 60) / 60.0))
    end
  end
  # 合計時間計算用
  def totalseconds(started_at, finished_at, nextday)
    @total_seconds ||= 0
    seconds = (finished_at - finished_at.beginning_of_day) - (started_at - started_at.beginning_of_day)
    seconds += 86400 if nextday
    @total_seconds += seconds
  end
  
  def working_times_sum(seconds)
    format("%.2f", seconds / 60 / 60.0)
  end
  
  # 不正な値はfalse返す
  def date_valid?(date)
    !!date.to_date rescue false
  end
  
  def first_day(date)
    !date.nil? ? Date.parse(date).beginning_of_month : Date.current.beginning_of_month
  end
  
  # 勤怠表示用データ取得
  def user_attendances_month_date
    @user.attendances.where('worked_on >= ? and worked_on <= ?', @first_day, @last_day).order('worked_on')
  end
  
  # 勤怠編集画面の値が正しいか
  def attendances_invalid?
    # conf_changeに何か入っている場合のみチェック
    attendances = true
    attendances_params.each do |id, item|
      if !item[:conf_change].blank?
        if (!item[:started_at].blank? && item[:finished_at].blank?) || (item[:started_at].blank? && !item[:finished_at].blank?)
          attendances = false
          break
        end
        
        item[:nextday] = item[:nextday] == "true" ? true : false # 文字列で入ってくるので変換
        
        if item[:started_at] > item[:finished_at] && item[:nextday] == false
          attendances = false
          break
        end
          
        if !item[:started_at].blank? && !item[:finished_at].blank? # form start fin入ってる
          if item[:conf_change].blank? # 上長入ってない
            data = Attendance.find(id)
            # 変更したことなくて(edit_request_permitがなくて)ボタンで出勤退勤登録していたら
            if !data.origin_start.nil? && !data.origin_fin.nil? && data.edit_request_permit.blank?
              
              # 以下は変更されていたらfalse
              bool_s = (data.started_at - data.started_at.beginning_of_day) == ((Time.parse(item[:started_at]) - Time.parse(item[:started_at]).beginning_of_day))    
              bool_e = (data.finished_at - data.finished_at.beginning_of_day) == ((Time.parse(item[:finished_at]) - Time.parse(item[:finished_at]).beginning_of_day))
        
              item[:conf_change] = item[:conf_change].blank? ? nil : item[:conf_change].to_i
              bool_next = data.nextday == item[:nextday]
              bool_boss = data.conf_change == item[:conf_change]
              # form DBデータ一致
              if bool_s && bool_e && bool_next && bool_boss
                next
              else
                # 既存のデータを修正するので上長必要
                attendances = false
                break
              end
            end
        
            if !data.started_at.blank? || !data.finished_at.blank? # DB start fin どちらか入っている(ボタンによるもの、編集したパターンあり)
              # 既存のデータを修正するので上長必要
              attendances = false
              break
            elsif data.edit_request_permit.blank? # 一度変更したら「申請中、承認」入る →1.編集画面で無から登録 2.出勤・退勤ボタンから登録
              attendances = false
              break
            elsif !data.edit_request_permit.blank? # 2回目以降の登録
              attendances = false
              break
            end
          else # 上長入っている
            next
          end
        elsif item[:started_at].blank? && item[:finished_at].blank? # form start finカラ
          if item[:conf_change].blank? # 上長カラ
            next
          else
            # 出勤・退勤がカラで上長が登録されなかった場合
            attendances = false
            break
          end
        end
      end
    end
    attendances
  end
  
  def ge_today?(day)
    day.worked_on <= Date.current
  end
  
  def future_month?(firstday)
    @first_day > Date.today.beginning_of_month
  end
end

# 各ユーザー残業申請モーダルからの値判定
def work_request_invalid?
  attendances = true
  item = work_request_params
  if item[:overwork_finish].blank? || item[:over_time_content].blank? || item[:conf_request].blank?
    attendances = false
  end
  attendances
end

# モーダル予定外時間を計算
def overwork_calculation(day)
  work_end_sec = (day.overwork_finish - day.overwork_finish.beginning_of_day) - (@user.designated_work_end_time - @user.designated_work_end_time.beginning_of_day)
  # 翌日で申請している場合は24時間(86400sec)足す
  over_time = day.next_day == 'false' ? work_end_sec : work_end_sec + 86400
  over_time = format("%.2f", over_time / 60 / 60.0)
  over_time
end
