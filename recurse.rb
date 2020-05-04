shape = {:m0=>{:m0=>{:m0=>[1,"C"], :m1=>[1,"C"]}, :m1=>[1,"C"]}, :m2=>[1,"C"]}
flattened = {}
def recurse(shape, flattened, prefix = nil)
  shape.each do |k,v|
    new_k = prefix.nil? ? k : "#{prefix}_#{k}"
    puts "#{k}, #{new_k}, #{v}, #{prefix}"
    if v.class == Array
      puts "v is an array"
      flattened[new_k] = v
    else
      puts "v is not an array"
      recurse(shape[k], flattened, new_k)
    end
  end
  flattened
end
puts recurse(shape, flattened)
