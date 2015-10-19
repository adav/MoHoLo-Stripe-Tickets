require 'sinatra'
require 'stripe'

set :publishable_key, ENV['PUBLISHABLE_KEY']
set :secret_key, ENV['SECRET_KEY']
set :server, %w[thin mongrel webrick]

Stripe.api_key = settings.secret_key

get '/' do
  erb :checkout
end

post '/paypig' do
  quantity = params[:quantity].to_i > 0 ? params[:quantity].to_i : 1
  @amount = 800 * quantity

  customer = Stripe::Customer.create(
    :email => params[:stripeEmail],
    :card  => params[:stripeToken]
  )

  charge = Stripe::Charge.create(
    :amount      => @amount,
    :description => "#{quantity}x Blind Pig Party Ticket",
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