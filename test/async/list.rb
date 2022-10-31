# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2022, by Samuel Williams.
# Copyright, 2022, by Shannon Skipper.

require 'async/list'

class Item < Async::List::Node
	def initialize(value)
		super()
		@value = value
	end
	
	attr_accessor :value
end

describe Async::List do
	let(:list) {Async::List.new}
	
	with '#append' do
		it "can append items" do
			list.append(Item.new(1))
			list.append(Item.new(2))
			list.append(Item.new(3))
			
			expect(list.each.map(&:value)).to be == [1, 2, 3]
		end
	end
	
	with '#prepend' do
		it "can prepend items" do
			list.prepend(Item.new(1))
			list.prepend(Item.new(2))
			list.prepend(Item.new(3))
			
			expect(list.each.map(&:value)).to be == [3, 2, 1]
		end
	end
	
	with '#delete' do
		it "can delete items" do
			item = Item.new(1)
			
			list.append(item)
			list.delete(item)
			
			expect(list.each.map(&:value)).to be(:empty?)
		end
		
		it "can't remove an item twice" do
			item = Item.new(1)
			
			list.append(item)
			list.delete(item)
			
			expect do
				list.delete(item)
			end.to raise_exception(ArgumentError, message: be =~ /not in a list/)
		end
		
		it "can delete item from the middle" do
			item = Item.new(1)
			
			list.append(Item.new(2))
			list.append(item)
			list.append(Item.new(3))
			
			list.delete(item)
			
			expect(list.each.map(&:value)).to be == [2, 3]
		end
	end
	
	with 'Node#delete!' do
		it "can't remove an item twice" do
			item = Item.new(1)
			
			list.append(item)
			item.delete!
			
			expect do
				item.delete!
			end.to raise_exception(NoMethodError)
		end
	end
	
	with '#each' do
		it "can iterate over nodes while deleting them" do
			nodes = [Item.new(1), Item.new(2), Item.new(3)]
			nodes.each do |node|
				list.append(node)
			end
			
			enumerated = []
			
			index = 0
			list.each do |node|
				enumerated << node
				
				# This tests that enumeration is tolerant of deletion:
				if index == 1
					# When we are indexing child 1, it means the current node is child 0 - deleting it shouldn't break enumeration:
					list.delete(nodes.first)
				end
				
				index += 1
			end
			
			expect(enumerated).to be == nodes
		end
	end
end