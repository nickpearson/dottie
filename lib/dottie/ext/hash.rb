class Hash
  
  ##
  # Creates a new Dottie::Freckle that wraps this Hash.
  
  def dottie
    Dottie::Freckle.new(self)
  end
  
  ##
  # Adds Dottie's behaviors to this Hash.
  
  def dottie!
    self.extend(Dottie::Methods)
  end
  
end
