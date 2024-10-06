CREATE TABLE product_hierarchy (
  "id" INTEGER,
  "parent_id" INTEGER,
  "level_text" VARCHAR(19),
  "level_name" VARCHAR(8)
);

INSERT INTO product_hierarchy
  ("id", "parent_id", "level_text", "level_name")
VALUES
  ('1', NULL, 'Womens', 'Category'),
  ('2', NULL, 'Mens', 'Category'),
  ('3', '1', 'Jeans', 'Segment'),
  ('4', '1', 'Jacket', 'Segment'),
  ('5', '2', 'Shirt', 'Segment'),
  ('6', '2', 'Socks', 'Segment'),
  ('7', '3', 'Navy Oversized', 'Style'),
  ('8', '3', 'Black Straight', 'Style'),
  ('9', '3', 'Cream Relaxed', 'Style'),
  ('10', '4', 'Khaki Suit', 'Style'),
  ('11', '4', 'Indigo Rain', 'Style'),
  ('12', '4', 'Grey Fashion', 'Style'),
  ('13', '5', 'White Tee', 'Style'),
  ('14', '5', 'Teal Button Up', 'Style'),
  ('15', '5', 'Blue Polo', 'Style'),
  ('16', '6', 'Navy Solid', 'Style'),
  ('17', '6', 'White Striped', 'Style'),
  ('18', '6', 'Pink Fluro Polkadot', 'Style');
