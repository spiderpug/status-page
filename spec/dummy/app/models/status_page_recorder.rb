class StatusPageRecorder < StatusPage::Metrics::ActiveRecordRecorder
  def model
    StatusPageMetric
  end

  def scope_column
    :scope
  end

  def value_column
    :value
  end

  def timestamp_column
    :created_at
  end
end
