require 'spec_helper'
require 'dottie/ext'

describe Array do
  
  describe 'Dottie extensions' do
    before :each do
      @arr = [{ 'a' => { 'b' => 'c' } }, 'd']
    end
    
    context 'untouched' do
      it "should not have Dottie's behavior" do
        expect{ @arr['[0].a.b'] }.to raise_error TypeError
      end
    end
    
    context 'wrapped' do
      let(:freckle) { @arr.dottie }
      
      it 'is no longer an Array' do
        expect(freckle).to_not be_an Array
      end
      it 'wraps an Array in a Dottie::Freckle' do
        expect(freckle).to be_a Dottie::Freckle
      end
      it 'acts like a regular Array for standard keys' do
        expect(freckle[1]).to eq 'd'
      end
      it "has Dottie's behavior" do
        expect(freckle['[0].a.b']).to eq 'c'
      end
      it "does not add Dottie's behavior to the original Array" do
        expect{ @arr['[0].a.b'] }.to raise_error TypeError
      end
    end
    
    context 'mixed in' do
      before :each do
        @arr.dottie!
      end
      
      it 'is still an Array' do
        expect(@arr).to be_a Array
      end
      it 'acts like a regular Array for standard keys' do
        expect(@arr[1]).to eq 'd'
      end
      it "adds Dottie's behavior to a Array" do
        expect(@arr['[0].a.b']).to eq 'c'
      end
    end
    
  end
  
end
