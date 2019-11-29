CSV.generate do |csv|
  csv_column_names = %w(日付 出社 退社 備考)
  csv << csv_column_names
  @attendances.each do |attendance|
    work = attendance.worked_on.nil? ?      "" : attendance.worked_on
    start = attendance.started_at.nil? ?    "" : "#{attendance.started_at.hour}:#{attendance.started_at.min}"
    finish = attendance.finished_at.nil? ?  "" : "#{attendance.finished_at.hour}:#{attendance.finished_at.min}"
    note = attendance.note
    
    csv_column_values = [
      work,
      start,
      finish,
      note
    ]
    csv << csv_column_values
  end
end