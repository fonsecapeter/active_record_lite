
# refine String class for string manipulations
class String

  def tablize
    self.to_snake.pluralize
  end

  def classize
    self.to_camel.singlize
  end

  def constantize
    Object.const_get(self)
  end

  # takes string in camel case and converts to snake case
  def to_snake
    words = self
      .split(/([[:upper:]][[:lower:]]*)/)
      .select { |word| word.size > 0}
    lower_case_words = words.map { |word| word.downcase }
    lower_case_words.join('_')
  end

  # takes string in snake case and converts to camel case
  def to_camel
    words = self.split('_')
    capitalized_words = words.map { |word| word.capitalize }
    capitalized_words.join('')
  end

  # takes string and adds trailing `s`, can refine later...
  def pluralize
    self[-1] == 's' ? "#{self}es" : "#{self}s"
  end

  # takes string and removes trailing `s`, can refine later...
  def singlize
    if self[-2] == 'e' && self[-1] == 's'
      return self[0...-2]
    else
      if self[-1] == 's'
        return self[0...-1]
      else
        return self
      end
    end
  end

end
