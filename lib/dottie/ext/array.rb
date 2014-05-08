class Array
  
  ##
  # Creates a new Dottie::Freckle that wraps this Array.
  
  def dottie
    Dottie::Freckle.new(self)
  end
  
  ##
  # Adds Dottie's behaviors to this Array.
  
  def dottie!
    self.extend(Dottie::Methods)
  end
  
end
