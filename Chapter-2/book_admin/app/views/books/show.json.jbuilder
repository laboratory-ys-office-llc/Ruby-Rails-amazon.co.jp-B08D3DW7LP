# app/views/books/show.json.jbuilder
json.extract! @book, :id, :name, :price, :sales_status, :published_on
