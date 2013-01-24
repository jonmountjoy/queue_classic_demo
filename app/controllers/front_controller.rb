class FrontController < ApplicationController

  # display's the form, allowing someone to submit a job
  def new
  end

  # get's called from the form
  def create
    arg = params[:email]
    counter = Job.enqueue(arg)
    render :status => :accepted, :json => { jobId: counter }
  end

  def fetch
    counter = params[:counter]
    if Job.isDone?(counter)
      render :status => 200, :text => Job.getResult(counter)
    else
      render :status => 202, :text => ''
    end
  end
end
