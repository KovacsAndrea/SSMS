USE [Clarkson's Farm Activities2]
DROP TABLE helped_with
DROP TABLE shepherding
DROP TABLE shepherder
DROP TABLE project_details
DROP TABLE equipment
DROP TABLE ph_project
DROP TABLe planting_harvesting
Drop TABLE plant
DROP TABLE qualified_farmer
DROP TABLE pen_project
DROP TABLE shop_project
DROP TABLE building_material
DROP TABLE farm_shop;
DROP TABLE cash_register;
DROP TABLE shop_employee;
DROP TABLE car_park;
DROP TABLE chicken_pen;
DROP TABLE parcell
DROP TABLE dog
--DROP TABLE shepherder_vacation

CREATE TABLE parcell(
	parid INT NOT NULL UNIQUE,
	parcell_name VARCHAR(256),
	parcell_size INT,
	CONSTRAINT PK_parcell PRIMARY KEY (parid)
);

CREATE TABLE cash_register(
	crid INT NOT NULL,
	serial_number INT,
	CONSTRAINT PK_cash_register PRIMARY KEY (crid)
);

CREATE TABLE car_park(
	 cpid INT NOT NULL,
	 no_spaces INT,
	 CONSTRAINT PK_car_park PRIMARY KEY(cpid)
);

CREATE TABLE chicken_pen(
	 chpid INT NOT NULL,
	 no_chicken INT,
	 parcell_id INT NOT NULL,
	 CONSTRAINT PK_chicken_pen PRIMARY KEY(chpid),
	 CONSTRAINT FK_parcell FOREIGN KEY (parcell_id) REFERENCES parcell(parid)
	 ON DELETE CASCADE
	 ON UPDATE CASCADE,
);

CREATE TABLE shop_employee(
	empid INT,
	employee_name VARCHAR(30),
	employee_salary INT, 
	CNP VARCHAR(10),
	CONSTRAINT UQ_cnp UNIQUE(CNP),
    CONSTRAINT PK_shop_employee PRIMARY KEY (empid)
)

CREATE TABLE farm_shop(
	 fsid INT NOT NULL,
	 shop_name VARCHAR (256) NOT NULL,
	 cash_register_id INT NOT NULL,
	 car_park_id INT,
	 employee_id INT,
	 shop_description VARCHAR(MAX) CONSTRAINT DF_shop_description DEFAULT ('TBA'),
	 CONSTRAINT PK_farm_shop PRIMARY KEY (fsid),
	 CONSTRAINT FK_shop_employee FOREIGN KEY (employee_id) REFERENCES shop_employee(empid)
	 ON DELETE CASCADE
	 ON UPDATE CASCADE,
	 CONSTRAINT FK_cash_register FOREIGN KEY (cash_register_id) REFERENCES cash_register(crid) 
	 ON DELETE CASCADE
	 ON UPDATE CASCADE,
	 CONSTRAINT FK_car_park FOREIGN KEY (car_park_id) REFERENCES car_park (cpid) 
	 ON DELETE CASCADE
	 ON UPDATE CASCADE
);

CREATE TABLE building_material(
	 mid INT NOT NULL,
	 material_type VARCHAR(256) NOT NULL,
	 price_per_kg INT NOT NULL,
	 CONSTRAINT PK_building_material PRIMARY KEY (mid)
);

CREATE TABLE pen_project (
	building_material_id INT NOT NULL,
	chicken_pen_id INT,
	quantity INT NOT NULL,
	CONSTRAINT FK_building_material_p FOREIGN KEY (building_material_id) REFERENCES building_material (mid)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT FK_chicken_pen FOREIGN KEY (chicken_pen_id) REFERENCES chicken_pen (chpid)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
);

CREATE TABLE shop_project (
	building_material_id INT NOT NULL,
	farm_shop_id INT,
	quantity INT NOT NULL,
	CONSTRAINT FK_building_material_s FOREIGN KEY (building_material_id) REFERENCES building_material (mid)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT FK_farm_shop FOREIGN KEY (farm_shop_id) REFERENCES farm_shop (fsid)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
);

CREATE TABLE plant (
	plantid INT NOT NULL UNIQUE,
	plant_name VARCHAR(256) UNIQUE,
	needs_dry INT NOT NULL,
	fertilizer_quantity INT,
	price int NOT NULL,
	CONSTRAINT ck_needs_dry CHECK (needs_dry IN (1,0)),
	CONSTRAINT PK_plant_id PRIMARY KEY (plantid)
);

CREATE TABLE qualified_farmer(
	 qfid INT NOT NULL UNIQUE,
	 farmer_name VARCHAR(256),
	 salary INT NOT NULL,
	 email VARCHAR(256),
	 driving_permit INT NOT NULL,
	 CONSTRAINT ck_driving_permit CHECK (driving_permit IN (1,0)),
	 CONSTRAINT PK_farmer_id PRIMARY KEY (qfid),
);

CREATE TABLE planting_harvesting(
	phid INT NOT NULL UNIQUE,
	plant_id INT NOT NULL,
	planting_date DATE,
	harvesting_date DATE,
	parcell_id INT NOT NULL,
	seed_quantity INT NOT NULL,
	CONSTRAINT PK_planting_harvesting_id PRIMARY KEY (phid),
	CONSTRAINT FK_plant_id FOREIGN KEY (plant_id) REFERENCES plant (plantid)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT FK_parcell_harvesting_id FOREIGN KEY (parcell_id) REFERENCES parcell (parid)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
);


CREATE TABLE ph_project(
	phid INT NOT NULL,
	qfid INT NOT NULL,
	CONSTRAINT FK_ph_pr_id FOREIGN KEY (phid) REFERENCES planting_harvesting (phid)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT FK_farmer_id FOREIGN KEY (qfid) REFERENCES qualified_farmer (qfid)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
)


CREATE TABLE equipment(
	eqid INT NOT NULL UNIQUE,
	eq_name VARCHAR(256) NOT NULL,
	country_origin VARCHAR(256),
	rent_price_per_day INT,
	is_rented INT,
	CONSTRAINT ck_test_isrented CHECK (is_rented IN (1,0)),
	CONSTRAINT PK_equipment_id PRIMARY KEY (eqid),
);

CREATE TABLE project_details(
	ph_project INT NOT NULL,
	equipment_id INT NOT NULL,
	CONSTRAINT FK_project_id FOREIGN KEY (ph_project) REFERENCES planting_harvesting (phid)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT FK_eq_id FOREIGN KEY (equipment_id) REFERENCES equipment (eqid)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
);

CREATE TABLE shepherding (
	shid INT NOT NULL UNIQUE,
	parcell_id INT NOT NULL UNIQUE,
	no_sheep INT NOT NULL,
	food_per_day INT,
	CONSTRAINT PK_shepherding_id PRIMARY KEY (shid),
	CONSTRAINT FK_parcell_id FOREIGN KEY (parcell_id) REFERENCES parcell (parid)
	ON DELETE CASCADE
	ON UPDATE CASCADE
);

CREATE TABLE dog(
	dog_name VARCHAR(50),
	chip_number INT,
	region VARCHAR(50),
	age INT,
	CONSTRAINT PK_dog PRIMARY KEY (chip_number, region)
);

CREATE TABLE shepherder(
	shpid INT NOT NULL UNIQUE,
	dog_chip INT,
	dog_region VARCHAR(50),
	shepherder_name VARCHAR(256),
	salary INT NOT NULL,
	email VARCHAR(256),
	CONSTRAINT PK_shepherder_id PRIMARY KEY (shpid),
	CONSTRAINT FK_shepherder_dog FOREIGN KEY (dog_chip, dog_region) REFERENCES dog (chip_number, region)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
);

CREATE TABLE helped_with(
	shepherding_id INT NOT NULL,
	shepherder_id INT NOT NULL,
	CONSTRAINT FK_shing FOREIGN KEY (shepherding_id) REFERENCES shepherding (shid)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
	CONSTRAINT FK_sher FOREIGN KEY (shepherder_id) REFERENCES shepherder (shpid)
	ON DELETE CASCADE
	ON UPDATE CASCADE,
);

