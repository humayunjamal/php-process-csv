CREATE TABLE data (
  id int(8) NOT NULL,
  item_name varchar(250) COLLATE utf8_bin NOT NULL,
  price decimal(7,4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


CREATE TABLE `imported_file` (
  `id` int(11) NOT NULL,
  `name` varchar(255) COLLATE utf8_bin NOT NULL,
  `key` varchar(255) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

ALTER TABLE data
  ADD PRIMARY KEY (id);

ALTER TABLE imported_file
  ADD PRIMARY KEY (id);

ALTER TABLE imported_file
  MODIFY id int(11) NOT NULL AUTO_INCREMENT;
