CREATE TABLE TBMSUP.test
(
  TEST_ID VARCHAR2(32) NOT NULL,
  TEST_VALUE VARCHAR2(50),
  CONSTRAINT TEST_PK PRIMARY KEY (TEST_ID)
);

INSERT into TBMSUP.test values ('ABC','123');
