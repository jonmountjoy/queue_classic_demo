require 'erb'

class DemoWorker < QC::Worker

  # Do some work. The counter will be set when a Job is enqueued
  def DemoWorker.work(counter,arguments)
    puts "GOT IT: counter = #{counter}"
    puts "payload: #{arguments}"
    sleep(1)

    intermediate_results = "It took some time, but here is your text upcased: " + arguments.to_s.upcase

    # We want to render this in an HTML page, and store that as the Job result
    html = html_render(intermediate_results)

    Job.setResult(counter, html )
  end

  # Takes the intermediate result and renders it using an ERB template
  def DemoWorker.html_render(intermediate)
    begin
      av = ActionView::Base.new(Rails.root.join('app', 'views'))
      av.assign(var: intermediate)
      output = av.render(:template => 'output.html')
    rescue => ex
      output = ex
    end
    output
  end

end
