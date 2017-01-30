import { ajax } from 'discourse/lib/ajax';

export default Ember.Controller.extend({

  countries: ['Andorra','United Arab Emirates','Afghanistan','Antigua and Barbuda','Anguilla','Albania','Armenia','Netherlands Antilles','Angola','Antarctica','Argentina','American Samoa','Austria','Australia','Aruba','Aland Islands','Azerbaijan','Bosnia and Herzegovina','Barbados','Bangladesh','Belgium','Burkina Faso','Bulgaria','Bahrain','Burundi','Benin','Saint Barthelemy','Bermuda','Brunei','Bolivia','Brazil','Bahamas','Bhutan','Bouvet Island','Botswana','Belarus','Belize','Canada','Cocos (Keeling) Islands','Congo (Kinshasa)','Central African Republic','Congo (Brazzaville)','Switzerland','Ivory Coast','Cook Islands','Chile','Cameroon','China','Colombia','Costa Rica','Cuba','Cape Verde','Christmas Island','Cyprus','Czech Republic','Germany','Djibouti','Denmark','Dominica','Dominican Republic','Algeria','Ecuador','Estonia','Egypt','Western Sahara','Eritrea','Spain','Ethiopia','Finland','Fiji','Falkland Islands','Micronesia','Faroe Islands','France','Gabon','United Kingdom','Grenada','Georgia','French Guiana','Guernsey','Ghana','Gibraltar','Greenland','Gambia','Guinea','Guadeloupe','Equatorial Guinea','Greece','South Georgia and the South Sandwich Islands','Guatemala','Guam','Guinea-Bissau','Guyana','Hong Kong S.A.R., China','Heard Island and McDonald Islands','Honduras','Croatia','Haiti','Hungary','Indonesia','Ireland','Israel','Isle of Man','India','British Indian Ocean Territory','Iraq','Iran','Iceland','Italy','Jersey','Jamaica','Jordan','Japan','Kenya','Kyrgyzstan','Cambodia','Kiribati','Comoros','Saint Kitts and Nevis','North Korea','South Korea','Kuwait','Cayman Islands','Kazakhstan','Laos','Lebanon','Saint Lucia','Liechtenstein','Sri Lanka','Liberia','Lesotho','Lithuania','Luxembourg','Latvia','Libya','Morocco','Monaco','Moldova','Montenegro','Saint Martin (French part)','Madagascar','Marshall Islands','Macedonia','Mali','Myanmar','Mongolia','Macao S.A.R., China','Northern Mariana Islands','Martinique','Mauritania','Montserrat','Malta','Mauritius','Maldives','Malawi','Mexico','Malaysia','Mozambique','Namibia','New Caledonia','Niger','Norfolk Island','Nigeria','Nicaragua','Netherlands','Norway','Nepal','Nauru','Niue','New Zealand','Oman','Panama','Peru','French Polynesia','Papua New Guinea','Philippines','Pakistan','Poland','Saint Pierre and Miquelon','Pitcairn','Puerto Rico','Palestinian Territory','Portugal','Palau','Paraguay','Qatar','Reunion','Romania','Serbia','Russia','Rwanda','Saudi Arabia','Solomon Islands','Seychelles','Sudan','Sweden','Singapore','Saint Helena','Slovenia','Svalbard and Jan Mayen','Slovakia','Sierra Leone','San Marino','Senegal','Somalia','Suriname','Sao Tome and Principe','El Salvador','Syria','Swaziland','Turks and Caicos Islands','Chad','French Southern Territories','Togo','Thailand','Tajikistan','Tokelau','Timor-Leste','Turkmenistan','Tunisia','Tonga','Turkey','Trinidad and Tobago','Tuvalu','Taiwan','Tanzania','Ukraine','Uganda','United States Minor Outlying Islands','United States','Uruguay','Uzbekistan','Vatican','Saint Vincent and the Grenadines','Venezuela','British Virgin Islands','U.S. Virgin Islands','Vietnam','Vanuatu','Wallis and Futuna','Samoa','Yemen','Mayotte','South Africa','Zambia','Zimbabwe','US Armed Forces' , 'Venezuela'],

  states: ['AK','AZ','AR','CA','CO','CT','DE','DC','FL','GA','HI','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY'],

  expMonths: ['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12'],

  expYears: [2017,2018,2019],

  memberDetails: {"first_name": "", "last_name": "", "address_1":"", "address_2":"", "city":"", "billing_state":"", "postal_code":"", "country":"United States", "phone":"", "card_number":"", "expiration_month":"", "expiration_year":"", "cvv":"",},

  _init: function() {
    if (this.currentUser){
      this.set('checkoutState', 'billing-payment');
    }
    else{
      this.set('checkoutState', "sign-in")
    };
  }.on('init'),

  actions: {

    submitBillingPayment: function() {
      var data = this.get("memberDetails");
      return ajax("/league/checkout/billing-payment.json", {
        data: JSON.stringify({"league_billing_payment": data}),
        type: 'POST',
        dataType: 'json',
        contentType: 'application/json'
      }).then(function(result) {
        console.log(result);
        this.set('checkoutState', "verify");
      });
    }
  }
});