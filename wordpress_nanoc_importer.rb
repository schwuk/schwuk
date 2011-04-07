require 'rubygems'
require 'wpxml_parser'
require 'nanoc3'
require 'fileutils'

XML_PATH = '/Users/dave/Downloads/wordpress.2011-04-07.xml'
NANOC_PATH = '.'

class WordpressNanocImporter
  include WpxmlParser

  def initialize(source_xml_path, target_path)
    @target_path = target_path
    @blog = Blog.new(source_xml_path)
  end
  
  def run
    FileUtils.cd(@target_path) do
      site = Nanoc3::Site.new('.')

      @blog.posts.each do |post|
        body = post.body
        attributes = build_post_attributes(post)
        identifier = build_post_identifier(post)

        site.data_sources[0].create_item(body, attributes, identifier)
      end
    end
  end

  private

  def build_post_attributes(post)
    { :title      => post.title, 
      :created_at => post.date,
      :kind       => 'article',
      :tags       => post.categories }
  end
  
  def build_post_identifier(post)
    "/articles/#{post.date.strftime('%Y/%m/%d')}/#{post.slug}/"
  end
end

importer = WordpressNanocImporter.new(XML_PATH, NANOC_PATH)
importer.run
