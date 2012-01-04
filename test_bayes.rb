require 'test/unit'
require 'bayes'

class TestBayes < Test::Unit::TestCase

  # stolen from Classifier gem test suite:
  # https://github.com/cardmagic/classifier/blob/master/test/bayes/bayesian_test.rb
	def test_classification
	  b = Bayes.new
		b.train :interesting, "here are some good words. I hope you love them"
		b.train :uninteresting, "here are some bad words, I hate you"
		assert_equal :uninteresting, b.classify("I hate bad words and you")
	end
end