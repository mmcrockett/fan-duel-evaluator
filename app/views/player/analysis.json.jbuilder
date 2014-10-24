json.array!(@analysis_data) do |d|
  json.extract! d, :name, :pts, :budget, :s
end
