require 'sinatra'
require 'stripe'

set :publishable_key, ENV['PUBLISHABLE_KEY']
set :secret_key, ENV['SECRET_KEY']
set :server, %w[thin mongrel webrick]

set :ticket_name, ENV['TICKET_NAME']
set :ticket_price, ENV['TICKET_PRICE_PENCE'].to_i

Stripe.api_key = settings.secret_key

get '/' do
  erb :checkout, :locals => {:name => :ticket_name, :price => :ticket_price}
end

post '/pay' do
  quantity = params[:quantity].to_i > 0 ? params[:quantity].to_i : 1
  @amount = :ticket_price * quantity

  customer = Stripe::Customer.create(
    :email => params[:stripeEmail],
    :card  => params[:stripeToken]
  )

  charge = Stripe::Charge.create(
    :amount      => @amount,
    :description => "#{quantity}x #{:ticket_name} Ticket",
    :currency    => 'gbp',
    :customer    => customer
  )

  '{"success":"true"}'
end

get '/seeyousoon' do
  erb :thankyou
end

error Stripe::CardError do
  env['sinatra.error'].message
end