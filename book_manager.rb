def prompt(msg, integer_required = true)
  print(msg)
  if integer_required
    gets.chomp.to_i
  else
    gets.chomp
  end
end


class BookManager
  FILE_NAME = 'books.txt'
  OPERATIONS = { 1 => :index, 2 => :create_book, 3 => :edit_book, 4 => :search_books, 5 => :exit }

  def initialize
    @library = {}
    @next_id = nil
    load_books
    show_available_operations_and_perform_chosen_one
  end

  private

  def load_books
    File.foreach(FILE_NAME)  do |line|
      book_attributes = line.split(',')
      book = Book.new(id: book_attributes[0].to_i, title: book_attributes[1], author: book_attributes[2],
                      description: book_attributes[3].chomp)
      @library[book.id] = book
      @next_id = book.id + 1
    end
    @next_id = 1 if @next_id.nil?
    puts "Loaded #{@next_id - 1} books into the library"
  end

  def show_available_operations_and_perform_chosen_one
    puts '==== Book Manager ===='
    puts '      1) View all books'
    puts '      2) Add a book'
    puts '      3) Edit a book'
    puts '      4) Search for a book'
    puts '      5) Save and exit'
    operation = prompt('Choose[1-5]: ')
    while OPERATIONS[operation].nil?
      puts "Sorry given operation doesn't exist, please enter a valid one "
      operation = prompt('Choose[1-5]: ')
    end
    send(OPERATIONS[operation])
  end

  def index
    puts '==== View Books ===='
    puts
    print_books_ids_and_titles
    puts
    puts 'To view details enter the book ID, to return press <Enter>.'
    book_id = prompt('Book ID: ')
    until book_id == 0
      if @library[book_id].nil?
        puts 'There is no book with given ID, Please Enter a vaild book id or press <Enter> to return'
        book_id = prompt('Book ID: ')
      else
        @library[book_id].print_attributes
        puts 'To view details enter the book ID, to return press <Enter>.'
        book_id = prompt('Book ID: ')
      end
    end
    show_available_operations_and_perform_chosen_one
  end

  def create_book
    book = Book.create_new(id: @next_id)
    @library[@next_id] = book
    @next_id += 1
    show_available_operations_and_perform_chosen_one
  end

  def edit_book
    puts '==== Edit a Book ===='
    puts
    print_books_ids_and_titles
    puts
    puts 'Enter the book ID of the book you want to edit, to return press <Enter>.'
    book_id = prompt('Book ID: ')
    until book_id == 0
      if @library[book_id].nil?
        puts 'There is no book with given ID, Please Enter a vaild book id or press <Enter> to return'
        book_id = prompt('Book ID: ')
      else
        @library[book_id].update_attributes
        puts 'Book saved'
        puts 'Enter the book ID of the book you want to edit, to return press <Enter>.'
        book_id = prompt('Book ID: ')
      end
    end
    show_available_operations_and_perform_chosen_one
  end

  def search_books
    puts '==== Search ===='
    puts
    puts '==== Choose field to search in ===='
    Book::ATTRIBUTES_ORDER.each do |order, attribute|
      puts "      #{order}) #{attribute.to_s.capitalize}"
    end
    attribute_order = prompt('Choose[1-3]: ')
    until attribute_order > 0 && attribute_order < 4
      puts 'We could not find given field, Please select field to search in'
      attribute_order = prompt('Choose[1-3]: ')
    end
    puts
    puts 'Type in one or more key words to search for'
    query = prompt('Search: ', false)
    books_ids_that_match_query = []
    @library.each do |book_id, book|
      if book.match_query(attribute_order, query)
        books_ids_that_match_query << book_id
      end
    end
    puts 'The following books matched your query. Enter the book ID to see more details, or press <Enter> to return'
    print_books_ids_and_titles(books_ids_that_match_query)
    puts
    book_id = prompt('Book ID: ')
    puts
    until book_id == 0
      if !books_ids_that_match_query.include?(book_id)
        puts 'Required book is not from the list that matches the query, please choose one from the given list or press <Enter> to return'
        book_id = prompt('Book ID: ')
      else
        @library[book_id].print_attributes
        puts
        book_id = prompt('Book ID: ')
      end
    end
    show_available_operations_and_perform_chosen_one
  end

  def exit
    File.write(FILE_NAME, @library.values.map(&:format_for_save).join("\n"))
    puts 'Library saved'
  end

  def print_books_ids_and_titles(specific_books_ids = false)
    if specific_books_ids
      specific_books_ids.each do |id|
        puts "[#{id}] #{@library[id].title}"
      end
    else
      @library.each do |id, book|
        puts "[#{id}] #{book.title}"
      end
    end
  end
end

class Book
  ATTRIBUTES_ORDER = { 1 => :title, 2 => :author, 3 => :description}

  attr_reader :id
  attr_accessor :title, :author, :description

  def initialize(id:, title:, author:, description:)
    @id = id
    @title = title
    @author = author
    @description = description
  end

  def self.create_new(id:)
    puts '==== Add a Book ===='
    puts
    puts 'Please enter the following information:'
    puts
    title = prompt('      Title: ', false)
    author = prompt('      Author: ', false)
    description = prompt('      Description: ', false)
    book = new(id: id, title: title, author: author, description: description)
    puts "Book #{id} Saved"
    book
  end

  def print_attributes
    puts "      ID: #{id}"
    puts "      Title: #{title}"
    puts "      Author: #{author}"
    puts "      Description: #{description}"
    puts
  end

  def update_attributes
    puts 'Input the following information. To leave a field unchanged, hit <Enter>'
    title = prompt("      Title [#{self.title}]: ", false)
    self.title = title if title.size != 0
    author = prompt("      Author [#{self.author}]: ", false)
    self.author = author if author.size != 0
    description = prompt("      Description [#{self.description}]: ", false)
    self.description = description if description.size != 0
    puts
    self
  end

  def format_for_save
    "#{id},#{title},#{author},#{description}"
  end

  def match_query(attribute_order, query)
    self.send(ATTRIBUTES_ORDER[attribute_order]).include?(query)
  end
end
BookManager.new
