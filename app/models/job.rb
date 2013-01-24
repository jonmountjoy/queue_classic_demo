class Job

  def Job.enqueue(arguments)
    counter = REDIS.incr("unique_counter")
    QC.enqueue("DemoWorker.work", counter, arguments)
    counter
  end

  def Job.setResult(counter, result)
    REDIS.set(counter,result)
  end

  def Job.getResult(counter)
    REDIS.get(counter)
  end

  def Job.isDone?(counter)
    !REDIS.get(counter).nil?
  end

end