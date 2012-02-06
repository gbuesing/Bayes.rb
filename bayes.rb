require 'rubygems'
require 'stopwords'
require 'stemmer/porter'

# adapted from https://github.com/sausheong/naive-bayes
class Bayes  
  attr_reader :categories, :doc_count
  
  def initialize
    @categories = Hash.new {|hsh, key| hsh[key] = Category.new(key, self) }
    @doc_count = 0
  end
  
  def train category, doc
    @doc_count += 1
    @categories[category].train doc
  end
  
  def classify doc, threshold=1.5
    probs = probabilities(doc)
    best, second_best = probs.pop, probs.pop
    
    if best[:value]/second_best[:value] > threshold
      best[:name]
    else
      :unknown
    end
  end
  
  def probabilities doc
    probs = @categories.map do |name,cat| 
      {:name => name, :value => cat.probability(doc)}
    end
    probs.sort! {|a,b| a[:value] <=> b[:value]}
    probs
  end
  
  class Category
    attr_reader :name, :doc_count, :word_count, :counts_by_word
    
    def initialize name, parent
      @name = name
      @parent = parent
      @doc_count = 0
      @word_count = 0
      @counts_by_word = Hash.new(0)
    end
    
    def train doc
      @doc_count += 1

      words_from_doc(doc).each do |word|
        @word_count += 1
        @counts_by_word[word] += 1
      end
    end
    
    def probability doc
      doc_probability(doc) * category_probability
    end
    
    private
      def category_probability
        @doc_count.to_f / @parent.doc_count.to_f
      end
    
      def doc_probability doc
        words_from_doc(doc).inject(1) do |doc_prob, word| 
          doc_prob *= word_probability(word)
        end
      end
    
      def word_probability word
        # add 1 to word count so that words that have never been added
        # in training will have > 0 probability
        (@counts_by_word[word] + 1) / @word_count.to_f
      end
    
      def words_from_doc doc
        words = doc.split(' ').map do |word|
          word.downcase!
          stem = word.stem
          if Stopwords.valid?(stem)
            stem
          end
        end
        words.compact!
        words
      end
  end
end
