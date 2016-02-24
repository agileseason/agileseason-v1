class Graphs::AgeController < ApplicationController
  def index
    @data = [
      { index: 1, number: 1, days: 60, age: :n8 },
      { index: 2, number: 2, days: 30, age: :n4 },
      { index: 3, number: 101, days: 25, age: :n2 },
      { index: 4, number: 201, days: 15, age: :n1 },
      { index: 5, number: 301, days: 5, age: :n0 },
    ]
  end
end
