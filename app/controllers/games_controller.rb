require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = []
    10.times do
      @letters.push(('A'..'Z').to_a[rand(0..26)])
    end
  end

  def score
    @answer = params[:answer]
    @letters = params[:letters]
    attempt_check = JSON.parse(URI.open("https://wagon-dictionary.herokuapp.com/#{@answer}").read)
    if attempt_check['found']
      @message = gen_message(@letters, @answer)
    else
      @message = "Sorry but #{@answer.upcase} does not seem to be a valid English word..."
    end
    @message.start_with?('Congratulations!') ? @score = @answer.size : @score = 0
  end

  private

  def gen_message(letters, answer)
    letterfreq = {}
    letters.split.each do |a|
      letterfreq.key?(a) ? letterfreq[a] += 1 : letterfreq[a] = 1
    end
    if check_win(letterfreq, answer)
      "Congratulations! #{answer.upcase} is a valid English word!"
    else
      "Sorry but #{answer.upcase} can't be built out of #{@letters}"
    end
  end

  def check_win(letterfreq, answer)
    win = true
    answer.chars.each do |c|
      c.upcase!
      letterfreq.key?(c) && letterfreq[c].positive? ? letterfreq[c] -= 1 : win = false
    end
    win
  end
end
