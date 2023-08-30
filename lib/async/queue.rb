# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2018-2022, by Samuel Williams.
# Copyright, 2019, by Ryan Musgrave.
# Copyright, 2020-2022, by Bruno Sutic.

require_relative 'notification'

module Async
	# A queue which allows items to be processed in order.
	# @public Since `stable-v1`.
	class Queue
		def initialize(parent: nil, available: Notification.new)
			super()
			
			@items = []
			@parent = parent
			@available = available
		end
		
		attr :items
		
		def size
			@items.size
		end

		def empty?
			@items.empty?
		end
		
		def <<(item)
			@items << item
			
			@available.signal unless self.empty?
		end
		
		def enqueue(*items)
			@items.concat(items)
			
			@available.signal unless self.empty?
		end
		
		def dequeue
			while @items.empty?
				@available.wait
			end
			
			@items.shift
		end
		
		def async(parent: (@parent or Task.current), &block)
			while item = self.dequeue
				parent.async(item, &block)
			end
		end
		
		def each
			while item = self.dequeue
				yield item
			end
		end
		
		def signal(value)
			self.enqueue(value)
		end
		
		def wait
			self.dequeue
		end
	end
	
	# @public Since `stable-v1`.
	class LimitedQueue < Queue
		def initialize(limit = 1, full: Notification.new, **options)
			super(**options)
			
			@limit = limit
			@full = full
		end
		
		attr :limit
		
		# @returns [Boolean] Whether trying to enqueue an item would block.
		def limited?
			@items.size >= @limit
		end
		
		def <<(item)
			while limited?
				@full.wait
			end
			
			super
		end
		
		def enqueue *items
			while !items.empty?
				while limited?
					@full.wait
				end
				
				available = @limit - @items.size
				@items.concat(items.shift(available))
				
				self.signal unless self.empty?
			end
		end
		
		def dequeue
			item = super
			
			@full.signal
			
			return item
		end
	end
end
