StandardLegends = new Mongo.Collection(null);

Template.single.helpers({
  settings: function() {
    return {
      position: Session.get("position"),
      limit: 10,
      rules: [
        {
          // token: '',
          collection: StandardLegends,
          field: 'legend',
          matchAll: true,
          template: Template.standardLegends
        }
      ]
    };
  },
  legends: function() {
    return StandardLegends.find();
  }
});

[
  {
    legend: '110° HOT WATER RETURN',
    code: '355',
    year: '2007',
    color: 'White',
    bg: 'Green'
  },
  {
    legend: '110° HOT WATER RETURN',
    code: '360',
    year: '1996',
    color: 'Black',
    bg: 'Yellow'
  },
  {
    legend: '110° HOT WATER SUPPLY',
    code: '361',
    year: '2007',
    color: 'White',
    bg: 'Green'
  },
  {
    legend: '110° HOT WATER SUPPLY',
    code: '356',
    year: '1996',
    color: 'Black',
    bg: 'Yellow'
  },
  {
    legend: '140° HOT WATER RETURN',
    code: '357',
    year: '2007',
    color: 'White',
    bg: 'Green'
  },
  {
    legend: '140° HOT WATER RETURN',
    code: '362',
    year: '1996',
    color: 'Black',
    bg: 'Yellow'
  },
  {
    legend: '140° HOT WATER SUPPLY',
    code: '364',
    year: '2007',
    color: 'White',
    bg: 'Green'
  },
  {
    legend: '140° HOT WATER SUPPLY',
    code: '358',
    year: '1996',
    color: 'Black',
    bg: 'Yellow'
  },
  {
    legend: 'ACID',
    code: '100',
    year: '2007',
    color: 'Black',
    bg: 'Orange'
  },
  {
    legend: 'ACID',
    code: '108',
    year: '1996',
    color: 'Black',
    bg: 'Yellow'
  },
  {
    legend: 'ACID VENT',
    code: '102',
    year: '2007',
    color: 'Black',
    bg: 'Orange'
  },
  {
    legend: 'ACID VENT',
    code: '106',
    year: '1996',
    color: 'Black',
    bg: 'Yellow'
  },
  {
    legend: 'ACID WASTE',
    code: '105',
    year: '2007',
    color: 'Black',
    bg: 'Orange'
  },
  {
    legend: 'ACID WASTE',
    code: '107',
    year: '1996',
    color: 'Black',
    bg: 'Yellow'
  },
  {
    legend: 'AIR',
    code: '111',
    year: '2007',
    color: 'White',
    bg: 'Blue'
  },
  {
    legend: 'AMMONIA',
    code: '115',
    year: '2007',
    color: 'Black',
    bg: 'Orange'
  },
  {
    legend: 'AMMONIA',
    code: '117',
    year: '1996',
    color: 'Black',
    bg: 'Yellow'
  },
  {
    legend: 'ARGON',
    code: '118',
    year: '2007',
    color: 'White',
    bg: 'Green'
  },
  {
    legend: 'ASBESTOS FREE',
    code: '119',
    year: '2007',
    color: 'White',
    bg: 'Blue'
  },
  {
    legend: 'BOILER BLOW DOWN',
    code: '120',
    year: '2007',
    color: 'White',
    bg: 'Green'
  },
  {
    legend: 'BOILER FEED WATER',
    code: '121',
    year: '2007',
    color: 'White',
    bg: 'Green'
  },
  {
    legend: 'CARBON DIOXIDE',
    code: '122',
    year: '2007',
    color: 'Black',
    bg: 'Yellow'
  },
  {
    legend: 'CARBON DIOXIDE',
    code: '124',
    year: '2007',
    color: 'White',
    bg: 'Silver'
  },
  {
    legend: 'FREE FOOD',
    code: '42',
    year: '2014',
    color: 'Red',
    bg: 'White'
  },
  {
    legend: '',
    code: '',
    year: '',
    color: '',
    bg: ''
  }
].forEach(function (obj) {
  StandardLegends.insert(obj);
});
