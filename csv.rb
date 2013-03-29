#!/usr/env/ruby

require "csv"
require "debugger"
require "logger"
$logger = Logger.new STDOUT
$logger.level = Logger::WARN

class MovieKeeper
  attr_accessor :position,
    :const,
    :created,
    :modified,
    :description,
    :title,
    :type,
    :director,
    :rating,
    :runtime,
    :year,
    :genre,
    :votes,
    :release,
    :url

  def initialize(row)
    @position = row["position"].to_i
    @const = row["const"]
    @create = row["created"]
    @modified = row["modified"]
    @description = row["description"]
    @title = row["Title"]
    @type = row["Title type"]
    @director = row["Directors"]
    @rating = row["IMDb Rating"].to_f
    @runtime = row["Runtime (mins)"].to_i
    @year = row["Year"].to_i
    @genre = row["Genres"]
    @votes = row["Num. Votes"].to_i
    @relase = row["Release Date (month/day/year)"]
    @url = row["URL"]
  end

  def filter(filterList)
    @filter = filterList
  end

  def info
    infoString = ""
    if !@filter.nil?
      @filter.each do |filter|
        infoString += "#{filter}: #{send filter}\n"
      end
    else
      instance_variables.each do |var|
        infoString += "#{var}: #{instance_variable_get var}\n"
      end
    end
    return infoString+"\n"
  end
end


class MovieParser
  def initialize(filename)
    $logger.debug("initializing Parser")
    @filename = filename
    loadFromFile
    $logger.info("#{@movies.length} records found")
  end

  def getRandomMovie
    $logger.debug("getting random movie")
    return @movies.sample()
  end

  def createKeeper(row)
    return MovieKeeper.new row
  end

  def find(fields = nil, &blk)
    $logger.debug("finding a movie")
    hits = []
    @movies.each do |row|
      keep = createKeeper row
      blk = lambda &blk
      if blk.call keep
        if fields != nil
          keep.filter fields
        end
        hits << keep
      end
    end
    $logger.info("found #{hits.length} results")
    return hits
  end

  private
  def loadFromFile
    $logger.debug("loading movie from file")
    @movies = []
    @csv = CSV.open(@filename, "r", {:headers => true, :write_headers => true})
    @csv.each do |row|
      @movies << row.to_hash
    end
  end
end

a = MovieParser.new "1000movies.csv"
hits = a.find ["title", "rating"] do |movie| movie.rating >= 9 end

hits.each do |row| puts row.info end

other = a.find do |movie| movie.year > 1950 && movie.rating > 8 && movie.genre.include?("comedy") end
other.each do |row| puts row.info end
