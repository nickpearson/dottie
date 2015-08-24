require 'spec_helper'

describe Dottie do
  
  describe 'instantiation' do
    
    it 'creates a Dottie::Freckle from a Hash using Dottie[]' do
      hash = { 'a' => 'b' }
      expect(Dottie[hash]).to be_a Dottie::Freckle
    end
    it 'creates a Dottie::Freckle from a Hash using Dottie()' do
      hash = { 'a' => 'b' }
      expect(Dottie(hash)).to be_a Dottie::Freckle
    end
    it 'creates a Dottie::Freckle from an Array using Dottie[]' do
      arr = ['a', 'b', 'c']
      expect(Dottie[arr]).to be_a Dottie::Freckle
    end
    it 'creates a Dottie::Freckle from an Array using Dottie()' do
      arr = ['a', 'b', 'c']
      expect(Dottie(arr)).to be_a Dottie::Freckle
    end
    it 'returns a Dottie::Freckle<Hash> instead of rewrapping it using Dottie[]' do
      dottie = Dottie[{ 'a' => 'b' }]
      expect(Dottie[dottie]).to eq dottie
    end
    it 'returns a Dottie::Freckle<Array> instead of rewrapping it using Dottie[]' do
      dottie = Dottie[['a', 'b', 'c']]
      expect(Dottie[dottie]).to eq dottie
    end
    it 'returns a Dottie::Freckle<Hash> instead of rewrapping it using Dottie()' do
      dottie = Dottie({ 'a' => 'b' })
      expect(Dottie(dottie)).to eq dottie
    end
    it 'returns a Dottie::Freckle<Array> instead of rewrapping it using Dottie()' do
      dottie = Dottie(['a', 'b', 'c'])
      expect(Dottie(dottie)).to eq dottie
    end
    ['a', nil, 1].each do |val|
      it "fails to create a Dottie::Freckle from an invalid type (#{val.class}) using Dottie[]" do
        expect{ Dottie[val] }.to raise_error(TypeError)
      end
      it "fails to create a Dottie::Freckle from an invalid type (#{val.class}) using Dottie()" do
        expect{ Dottie(val) }.to raise_error(TypeError)
      end
    end
    
  end
  
  describe 'reading' do
    
    context 'simple' do
      let(:hash) {{ 'a' => 'b', 'c' => { 'd' => 'e' }}}
      
      it 'reads a standard key' do
        expect(Dottie.get(hash, 'a')).to eq 'b'
      end
      it 'returns nil for a missing standard key' do
        expect(Dottie.get(hash, 'd')).to be_nil
      end
      it 'reads a dotted key' do
        expect(Dottie.get(hash, 'c.d')).to eq 'e'
      end
      it 'returns nil for a missing dotted key' do
        expect(Dottie.get(hash, 'c.e')).to be_nil
      end
      it 'returns nil for a missing nested dotted key' do
        expect(Dottie.get(hash, 'c.e.g.x.y')).to be_nil
      end
      it 'returns nil when trying to walk into a non-Hash/Array' do
        expect(Dottie.get(hash, 'a.b')).to be_nil
      end
      it 'returns nil when trying to walk deep into a non-Hash/Array' do
        expect(Dottie.get(hash, 'a.b.c')).to be_nil
      end
    end
    
    context 'ending array indexes' do
      let(:hash) {{ 'a' => 'b', 'c' => ['d', 'e', 'f'] }}
      
      it 'reads an integer key' do
        expect(Dottie.get(hash, 'c[0]')).to eq 'd'
      end
      it 'reads a negative integer key' do
        expect(Dottie.get(hash, 'c[-1]')).to eq 'f'
      end
      it 'reads a named key (first)' do
        expect(Dottie.get(hash, 'c[first]')).to eq 'd'
      end
      it 'reads a named key (last)' do
        expect(Dottie.get(hash, 'c[last]')).to eq 'f'
      end
      it 'returns nil for a missing index' do
        expect(Dottie.get(hash, 'c[4]')).to be_nil
      end
      it 'returns nil for a missing array' do
        expect(Dottie.get(hash, 'x[4]')).to be_nil
      end
    end
    
    context 'middle array indexes' do
      let(:hash) {{ 'a' => 'b', 'c' => [{ 'd' => 'e' }, { 'f' => 'g' }] }}
      
      it 'reads an integer key' do
        expect(Dottie.get(hash, 'c[0].d')).to eq 'e'
      end
      it 'reads a negative integer key' do
        expect(Dottie.get(hash, 'c[-1].f')).to eq 'g'
      end
      it 'reads a named key (first)' do
        expect(Dottie.get(hash, 'c[first].d')).to eq 'e'
      end
      it 'reads a named key (last)' do
        expect(Dottie.get(hash, 'c[last].f')).to eq 'g'
      end
      it 'returns nil for a missing index' do
        expect(Dottie.get(hash, 'c[4].r')).to be_nil
      end
      it 'returns nil for a missing array' do
        expect(Dottie.get(hash, 'x[4].s')).to be_nil
      end
    end
    
    context 'consecutive array indexes' do
      let(:hash) {{ 'a' => 'b', 'c' => [ [{}, { 'd' => 'e' }] ] }}
      
      it 'reads an integer key' do
        expect(Dottie.get(hash, 'c[0][1].d')).to eq 'e'
      end
      it 'reads a negative integer key' do
        expect(Dottie.get(hash, 'c[-1][1].d')).to eq 'e'
      end
      it 'reads a named key (first)' do
        expect(Dottie.get(hash, 'c[first][last].d')).to eq 'e'
      end
      it 'reads a named key (last)' do
        expect(Dottie.get(hash, 'c[last][last].d')).to eq 'e'
      end
      it 'returns nil for a missing index' do
        expect(Dottie.get(hash, 'c[4][5]')).to be_nil
      end
      it 'returns nil for a missing array' do
        expect(Dottie.get(hash, 'x[4][5]')).to be_nil
      end
    end
    
  end
  
  describe 'key existence' do
    let(:hash) {{ 'a' => 'b', 'c' => { 'd' => ['e', 'f', 'g'] } }}
    
    it "finds a standard key" do
      expect(Dottie.has_key?(hash, 'a')).to be_true
    end
    it "does not find a missing standard key" do
      expect(Dottie.has_key?(hash, 'x')).to be_false
    end
    it "finds a Dottie key (Hash value)" do
      expect(Dottie.has_key?(hash, 'c.d')).to be_true
    end
    it "finds a Dottie key (Array element)" do
      expect(Dottie.has_key?(hash, 'c.d[0]')).to be_true
    end
    it "does not find a missing Dottie key (first part is a String)" do
      expect(Dottie.has_key?(hash, 'a.b')).to be_false
    end
    it "does not find a missing Dottie key (first part exists)" do
      expect(Dottie.has_key?(hash, 'c.x')).to be_false
    end
    it "does not find a missing Dottie key (outside Array bounds)" do
      expect(Dottie.has_key?(hash, 'c.d[4]')).to be_false
    end
    it "does not find a missing Dottie key (no part exists)" do
      expect(Dottie.has_key?(hash, 'x.y')).to be_false
    end
  end
  
  describe 'fetching' do
    let(:hash) {{ 'a' => 'b', 'c' => { 'd' => ['e', 'f', 'g'] } }}
    
    context 'no default' do
      it 'fetches a standard key' do
        expect(Dottie.fetch(hash, 'a')).to eq 'b'
      end
      it 'fetches a Dottie key (Hash value)' do
        expect(Dottie.fetch(hash, 'c.d')).to eq ['e', 'f', 'g']
      end
      it 'fetches a Dottie key (Array element)' do
        expect(Dottie.fetch(hash, 'c.d[1]')).to eq 'f'
      end
      it 'raises on a missing standard key' do
        expect{ Dottie.fetch(hash, 'x') }.to raise_error KeyError
      end
      it 'raises on a missing Dottie key' do
        expect{ Dottie.fetch(hash, 'x.y') }.to raise_error KeyError
      end
    end
    
    context 'with default' do
      it 'fetches a standard key' do
        expect(Dottie.fetch(hash, 'a', 'z')).to eq 'b'
      end
      it 'fetches a Dottie key' do
        expect(Dottie.fetch(hash, 'c.d', 'z')).to eq ['e', 'f', 'g']
      end
      it 'returns a default for a missing standard key' do
        expect(Dottie.fetch(hash, 'x', 'z')).to eq 'z'
      end
      it 'returns a default for a missing Dottie key' do
        expect(Dottie.fetch(hash, 'x', 'z')).to eq 'z'
      end
    end
    
    context 'with block' do
      it 'fetches a standard key' do
        expect(Dottie.fetch(hash, 'a'){ |key| key.upcase }).to eq 'b'
      end
      it 'fetches a Dottie key' do
        expect(Dottie.fetch(hash, 'c.d'){ |key| key.upcase }).to eq ['e', 'f', 'g']
      end
      it 'yields to a block for a missing standard key' do
        expect(Dottie.fetch(hash, 'x'){ |key| key.upcase }).to eq 'X'
      end
      it 'yields to a block for a missing Dottie key' do
        expect(Dottie.fetch(hash, 'x.y'){ |key| key.upcase }).to eq 'X.Y'
      end
    end
    
  end
  
  describe 'writing' do
    
    context 'simple' do
      before :each do
        @hash = { 'a' => 'b', 'c' => { 'd' => 'e' } }
      end
      
      it 'overwrites a standard key' do
        Dottie.set(@hash, 'c', 'd')
        expect(@hash).to eq({ 'a' => 'b', 'c' => 'd' })
      end
      it 'overwrites a dotted key' do
        Dottie.set(@hash, 'c.d', 'm')
        expect(@hash).to eq({ 'a' => 'b', 'c' => { 'd' => 'm' } })
      end
      it 'creates a value at a non-existent standard key' do
        Dottie.set(@hash, 'n', 'p')
        expect(@hash).to eq({ 'a' => 'b', 'c' => { 'd' => 'e' }, 'n' => 'p' })
      end
      it 'creates a hash at a non-existent dotted key' do
        Dottie.set(@hash, 'n.o', 'p')
        expect(@hash).to eq({ 'a' => 'b', 'c' => { 'd' => 'e' }, 'n' => { 'o' => 'p' } })
      end
      it 'raises an error when trying to write to a non-Hash/Array' do
        expect{ Dottie.set(@hash, 'a.b', 'r') }.to raise_error TypeError
      end
    end
    
    context 'array indexes' do
      before :each do
        @hash = { 'a' => 'b', 'c' => ['d', 'e', 'f'] }
      end
      
      it 'overwrites an array element (positive index)' do
        Dottie.set(@hash, 'c[0]', 'x')
        expect(@hash).to eq({ 'a' => 'b', 'c' => ['x', 'e', 'f'] })
      end
      it 'overwrites an array element (negative index)' do
        Dottie.set(@hash, 'c[-2]', 'y')
        expect(@hash).to eq({ 'a' => 'b', 'c' => ['d', 'y', 'f'] })
      end
      it 'creates an array at a non-existent key (positive index)' do
        Dottie.set(@hash, 'r[0]', 's')
        expect(@hash).to eq({ 'a' => 'b', 'c' => ['d', 'e', 'f'], 'r' => ['s'] })
      end
      it 'adds an array element' do
        Dottie.set(@hash, 'c[3]', 'g')
        expect(@hash).to eq({ 'a' => 'b', 'c' => ['d', 'e', 'f', 'g'] })
      end
    end
    
    context 'invalid' do
      before :each do
        @hash = { 'a' => 'b', 'c' => { 'd' => 'e' }, 'f' => ['g', 'h'] }
      end
      
      it 'raises an error when trying to write a Hash key to an Array' do
        expect{ Dottie.set(@hash, 'f.x', 'y') }.to raise_error TypeError
      end
      it 'raises an error when trying to write a Hash key to a non-Hash/Array' do
        expect{ Dottie.set(@hash, 'a.x', 'y') }.to raise_error TypeError
      end
      it 'raises an error when trying to write an Array index to a non-Hash/Array' do
        expect{ Dottie.set(@hash, 'a[0]', 'r') }.to raise_error TypeError
      end
      it 'does not raise an error when trying to write an Array index to a Hash' do
        Dottie.set(@hash, 'c[0]', 'm')
        expect(@hash).to eq({ 'a' => 'b', 'c' => { 'd' => 'e', 0 => 'm' }, 'f' => ['g', 'h'] })
      end
    end
    
  end
  
  describe 'key identification' do
    
    it 'recognizes a dotted key' do
      key = 'a.b.c'
      expect(Dottie.dottie_key?(key)).to be_true
    end
    
    it 'recognizes a bracketed key' do
      key = 'a[0]b'
      expect(Dottie.dottie_key?(key)).to be_true
    end
    
    it 'recognizes an array as a Dottie key' do
      key = ['a', 'b', 'c']
      expect(Dottie.dottie_key?(key)).to be_true
    end
    
    it 'does not recognize a normal key' do
      key = 'a_b_c'
      expect(Dottie.dottie_key?(key)).to be_false
    end
    
  end
  
  describe 'key parsing' do
    
    it 'returns a key array untouched' do
      arr = ['a', 'b', 'c']
      expect(Dottie.key_parts(arr)).to eq arr
    end
    
    it 'returns a non-Dottie key as a single-element array' do
      str = 'some_key'
      arr = [str]
      expect(Dottie.key_parts(str)).to eq arr
    end
    
    it 'converts a dotted key into an array' do
      str = 'a.b.c'
      arr = ['a', 'b', 'c']
      expect(Dottie.key_parts(str)).to eq arr
    end
    
    it 'converts a bracketed string key into an array' do
      str = 'a[b]c'
      arr = ['a', 'b', 'c']
      expect(Dottie.key_parts(str)).to eq arr
    end
    
    it 'treats integers as strings when part of a string (prefix)' do
      str = 'a.0b.c'
      arr = ['a', '0b', 'c']
      expect(Dottie.key_parts(str)).to eq arr
    end
    
    it 'treats integers as strings when part of a string (postfix)' do
      str = 'a.b1.c'
      arr = ['a', 'b1', 'c']
      expect(Dottie.key_parts(str)).to eq arr
    end
    
    it 'treats dashes as strings' do
      str = 'a.-.c'
      arr = ['a', '-', 'c']
      expect(Dottie.key_parts(str)).to eq arr
    end
    
    it 'converts a Dottie key with array indexes into a string/integer array' do
      str = 'a.b[0].c[-1]'
      arr = ['a', 'b', 0, 'c', -1]
      expect(Dottie.key_parts(str)).to eq arr
    end
    
    it 'converts a Dottie key with array references into a string/integer array' do
      str = 'a.b[first].c[last]'
      arr = ['a', 'b', 0, 'c', -1]
      expect(Dottie.key_parts(str)).to eq arr
    end
    
    it 'converts a Dottie key with bracketed array references into a string/integer array' do
      str = 'a.b[first].c[last]'
      arr = ['a', 'b', 0, 'c', -1]
      expect(Dottie.key_parts(str)).to eq arr
    end
    
    it 'converts a complex mix of strings and array indexes and references' do
      str = 'a.b.first.c[2].-3.d[last]'
      arr = ['a', 'b', 'first', 'c', 2, '-3', 'd', -1]
      expect(Dottie.key_parts(str)).to eq arr
    end
    
    it 'allows arbitrary strings using array index syntax' do
      str = 'a.b[middle].c'
      arr = ['a', 'b', 'middle', 'c']
      expect(Dottie.key_parts(str)).to eq arr
    end
    
    it 'allows dots as part of a key segment when enclosed in brackets' do
      str = 'a.[b.c].d'
      arr = ['a', 'b.c', 'd']
      expect(Dottie.key_parts(str)).to eq arr
    end
    
    it 'allows a dot before a bracketed array index' do
      str = 'a.b.[2].c'
      arr = ['a', 'b', 2, 'c']
      expect(Dottie.key_parts(str)).to eq arr
    end
    
    it 'does not require a dot after a bracketed array index' do
      str = 'a.b[2]c'
      arr = ['a', 'b', 2, 'c']
      expect(Dottie.key_parts(str)).to eq arr
    end
    
    it 'collapses multiple dots into a single dot' do
      str = 'a.b..c'
      arr = ['a', 'b', 'c']
      expect(Dottie.key_parts(str)).to eq arr
    end
    
  end
  
  describe 'key format variants' do
    let(:arr) { ['a', 0, 'b', 1, 'c', -2, 'd', -1, 'e'] }
    
    it 'parses dotted format' do
      str = 'a[0].b[1].c[-2].d[-1].e'
      expect(Dottie.key_parts(str)).to eq arr
    end
    
    it 'parses dotted format (with named array positions)' do
      str = 'a[first].b[1].c[-2].d[last].e'
      expect(Dottie.key_parts(str)).to eq arr
    end
    
    it 'parses mixed format (with optional dots)' do
      str = 'a.[0].b.[1].c.[-2].d.[-1].e'
      expect(Dottie.key_parts(str)).to eq arr
    end
    
    it 'parses mixed format (without optional dots)' do
      str = 'a[0]b[1]c[-2]d[-1]e'
      expect(Dottie.key_parts(str)).to eq arr
    end
    
    it 'parses consecutive array indexes and positions' do
      str = 'a.first[1][2]3[4]5.6.-7[-8]-9.[last]'
      arr = ['a', 'first', 1, 2, '3', 4, '5', '6', '-7', -8, '-9', -1]
      expect(Dottie.key_parts(str)).to eq arr
    end
    
  end
  
end
