#!/usr/bin/env ruby -wKU

# Mersh - Ruby 3D Mesh Manipulation
# Copyright (C) 2011 Tony Buser <tbuser@gmail.com> - http://tonybuser.com
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

require 'rubygems'
require 'json'
require 'digest/md5'

class Mersh
  VERSION = "0.0.2"
  attr_accessor :vertices, :faces, :normals
  
  def initialize(file)
    @vertices = []
    @faces    = []
    @normals  = []

    if file.class == String
      open(file)
    else
      @file = file
      parse
    end
  end
  
  def open(path)
    @file = File.open(path, 'rb')
    parse
  end

  def max
    [@vertices.collect{|v| v[0]}.max, @vertices.collect{|v| v[1]}.max, @vertices.collect{|v| v[2]}.max]
  end

  def min
    [@vertices.collect{|v| v[0]}.min, @vertices.collect{|v| v[1]}.min, @vertices.collect{|v| v[2]}.min]
  end

  def info
    {"min" => min, "max" => max}.to_json
  end

  def to_json(type='plain')
    case type
      when "threejs"
        json_hash = {
          "metadata" => {
            "formatVersion" => 3,
            "generatedBy"   => "Mersh"
          },
          "scale"         => 1.0,
          "materials"     => [],
          "vertices"      => @vertices.flatten,
          "morphTargets"  => [],
          "morphColors"   => [],
          "normals"       => [], # not needed surprisingly
          "colors"        => [],
          "uvs"           => [[]],
          "faces"         => @faces.collect{|f| f.unshift(0)}.flatten # requires first value in series to be UV, in our case always 0
        }
      else
        json_hash = { "vertices" => @vertices, "normals" => @normals, "faces" => @faces}
    end

    json_hash.to_json
  end
  
  private
  
  def parse
    if @file.readline =~ /^solid/i
      parse_ascii_stl
    else
      parse_binary_stl
    end
  end
  
  def parse_ascii_stl
    @vertices = []
    @faces    = []
    @normals  = []

    face_count   = 0
    vertex_count  = 0
    vertex_index = {}

    line_pos      = 1

    stl_data = @file.read
    
    stl_data.gsub!(/^\s*solid.*$/i, '')
    stl_data.gsub!(/^\s*facet normal /i, '').gsub!(/^\s*outer loop.*$/i, '')
    stl_data.gsub!(/^\s*vertex /i, '')
    stl_data.gsub!(/^\s*endloop.*$/i, '').gsub!(/^\s*endfacet.*$/i, '')
    stl_data.gsub!(/^\s*endsolid.*$/i, '')
    stl_data.gsub!(/^\s*$\n/i, '')
    
    stl_data.split("\n").each do |line|
      line_pos = 1 if line_pos > 4
      
      if line_pos == 1        
        @normals << line.split(" ").collect{|f| f.to_f}
      else
        vertex = line.split(" ").collect{|f| f.to_f}        
        
        # optimization, don't duplicate vertices
        vertex_hash = Digest::MD5.hexdigest(vertex.join(''))
        unless vertex_index.include?(vertex_hash)
          @vertices << vertex
          vertex_index[vertex_hash] = vertex_count
          vertex_count += 1
        end
        
        @faces[face_count] ||= []
        @faces[face_count] << vertex_index[vertex_hash]
      end
      
      line_pos += 1
      face_count += 1 if line_pos == 5
    end    
  end
  
  def parse_binary_stl
    @vertices = []
    @faces    = []
    @normals  = []
  
    vertex_count = 0
    vertex_index = {}
  
    @file.rewind
    
    # ignore header
    @file.seek 80, IO::SEEK_CUR
  
    face_count = @file.read(4).unpack("I")[0]
    
    face_count.times do |face_count|
      @normals << @file.read(12).unpack("fff")
      
      3.times do
        vertex = @file.read(12).unpack("fff")
        
        # optimization, don't duplicate vertices
        vertex_hash = Digest::MD5.hexdigest(vertex.join(''))
        unless vertex_index.include?(vertex_hash)
          @vertices << vertex
          vertex_index[vertex_hash] = vertex_count
          vertex_count += 1
        end
   
        @faces[face_count] ||= []
        @faces[face_count] << vertex_index[vertex_hash]
      end
  
      @file.seek 2, IO::SEEK_CUR
    end
  end
    
end