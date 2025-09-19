/* Create a table medication_stock in your Smart Old Age Home database. The table must have the following attributes:
 1. medication_id (integer, primary key)
 2. medication_name (varchar, not null)
 3. quantity (integer, not null)
 Insert some values into the medication_stock table. 
 Practice SQL with the following:
 */
 -- Q!: List all patients name and ages 
 -- Q2: List all doctors specializing in 'Cardiology'
 -- Q3: Find all patients that are older than 80
-- Q4: List all the patients ordered by their age (youngest first)
-- Q5: Count the number of doctors in each specialization
-- Q6: List patients and their doctors' names
-- Q7: Show treatments along with patient names and doctor names
-- Q8: Count how many patients each doctor supervises
-- Q9: List the average age of patients and display it as average_age
-- Q10: Find the most common treatment type, and display only that
-- Q11: List patients who are older than the average age of all patients
-- Q12: List all the doctors who have more than 5 patients
-- Q13: List all the treatments that are provided by nurses that work in the morning shift. List patient name as well. 
-- Q14: Find the latest treatment for each patient
-- Q15: List all the doctors and average age of their patients
-- Q16: List the names of the doctors who supervise more than 3 patients
-- Q17: List all the patients who have not received any treatments (HINT: Use NOT IN)
-- Q18: List all the medicines whose stock (quantity) is less than the average stock
-- Q19: For each doctor, rank their patients by age
-- Q20: For each specialization, find the doctor with the oldest patient
CREATE TABLE doctors (
    doctor_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    specialization TEXT NOT NULL
);
CREATE TABLE nurses (
    nurse_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    shift TEXT NOT NULL 
);
CREATE TABLE patients (
    patient_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    age INT NOT NULL,
    room_no INT NOT NULL,
    doctor_id INT REFERENCES doctors(doctor_id)
);
CREATE TABLE treatments (
    treatment_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    nurse_id INT REFERENCES nurses(nurse_id),
    treatment_type TEXT NOT NULL,
    treatment_time TIMESTAMP NOT NULL
);
CREATE TABLE sensors (
    sensor_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    sensor_type TEXT NOT NULL,
    reading NUMERIC NOT NULL,
    reading_time TIMESTAMP NOT NULL
);
INSERT INTO doctors (name, specialization) VALUES
('Dr. Smith', 'Geriatrics'),
('Dr. Johnson', 'Cardiology'),
('Dr. Lee', 'Neurology'),
('Dr. Patel', 'Endocrinology'),
('Dr. Adams', 'General Medicine');
INSERT INTO nurses (name, shift) VALUES
('Nurse Ann', 'Morning'),   
('Nurse Ben', 'Evening'),   
('Nurse Eva', 'Night'),     
('Nurse Kim', 'Morning'),   
('Nurse Omar', 'Evening');  
INSERT INTO patients (name, age, room_no, doctor_id) 
VALUES
('Alice', 82, 101, 1),
('Bob', 79, 102, 2),
('Carol', 85, 103, 1),
('David', 88, 104, 3),
('Ella', 77, 105, 2),
('Frank', 91, 106, 4);
INSERT INTO treatments (patient_id, nurse_id, treatment_type, treatment_time) VALUES
(1, 1, 'Physiotherapy', '2025-09-10 09:00:00'),
(2, 2, 'Medication', '2025-09-10 18:00:00'),
(1, 3, 'Medication', '2025-09-11 21:00:00'),
(3, 1, 'Checkup', '2025-09-12 10:00:00'),
(4, 2, 'Physiotherapy', '2025-09-12 17:00:00'),
(5, 5, 'Medication', '2025-09-12 18:00:00'),
(6, 4, 'Physiotherapy', '2025-09-13 09:00:00');
CREATE TABLE medication_stock (
    medication_id SERIAL PRIMARY KEY, 
    medication_name VARCHAR(50) NOT NULL,
    quantity INT NOT NULL 
);


INSERT INTO medication_stock (medication_name, quantity) VALUES
('Aspirin ', 120),   
('Ibuprofen ', 80),    
('Metformin ', 50),  
('Lisinopril ', 30), 
('Paracetamol ', 150); 
--q1
SELECT name AS patient_name, age AS patient_age 
FROM patients;
--q2
SELECT name AS cardiology_doctor_name, specialization AS specialization 
FROM doctors 
WHERE specialization = 'Cardiology';
--q3
SELECT *
FROM patients 
WHERE age > 80;
--q4
SELECT name AS patient_name, age AS patient_age 
FROM patients 
ORDER BY age ASC;
--q5
SELECT specialization AS doctor_specialization, COUNT(doctor_id) AS doctor_count 
FROM doctors 
GROUP BY specialization;
--q6
SELECT 
    p.name AS patient_name, 
    d.name AS doctor_name 
FROM patients p
JOIN doctors d 
ON p.doctor_id = d.doctor_id;
--q7
SELECT 
    t.treatment_type AS treatment_type, 
    t.treatment_time AS treatment_time, 
    p.name AS patient_name, 
    d.name AS doctor_name 
FROM treatments t
JOIN patients p ON t.patient_id = p.patient_id
JOIN doctors d ON p.doctor_id = d.doctor_id;
--q8
SELECT 
    d.name AS doctor_name, 
    COUNT(p.patient_id) AS supervised_patient_count 
FROM doctors d
LEFT JOIN patients p ON d.doctor_id = p.doctor_id
GROUP BY d.doctor_id, d.name;
--q9
SELECT AVG(age) AS average_age 
FROM patients;
--q10
WITH treatment_counts AS (
    SELECT 
        treatment_type, 
        COUNT(*) AS count
    FROM treatments 
    GROUP BY treatment_type
)
SELECT treatment_type AS most_common_treatment_type 
FROM treatment_counts 
WHERE count = (SELECT MAX(count) FROM treatment_counts);
--q11
SELECT name AS patient_name, age AS patient_age 
FROM patients 
WHERE age > (SELECT AVG(age) FROM patients);
--q12
SELECT 
    d.name AS doctor_name, 
    COUNT(p.patient_id) AS supervised_patient_count 
FROM doctors d
LEFT JOIN patients p ON d.doctor_id = p.doctor_id
GROUP BY d.name
HAVING COUNT(p.patient_id) > 5;
--q13
SELECT 
    t.treatment_type AS treatment_type, 
    t.treatment_time AS treatment_time, 
    n.name AS nurse_name, 
    p.name AS patient_name 
FROM treatments t
JOIN nurses n ON t.nurse_id = n.nurse_id
JOIN patients p ON t.patient_id = p.patient_id
WHERE n.shift = 'Morning';
--q14
WITH ranked_treatments AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY treatment_time DESC) AS rn
    FROM treatments
)
SELECT 
    p.name AS patient_name, 
    rt.treatment_type AS latest_treatment_type, 
    rt.treatment_time AS latest_treatment_time 
FROM ranked_treatments rt
JOIN patients p ON rt.patient_id = p.patient_id
WHERE rt.rn = 1;
--q15
SELECT 
    d.name AS doctor_name, 
    COALESCE(AVG(p.age), 0) AS avg_patient_age 
FROM doctors d
LEFT JOIN patients p ON d.doctor_id = p.doctor_id
GROUP BY d.name;
--q16
SELECT d.name AS doctor_name 
FROM doctors d
LEFT JOIN patients p ON d.doctor_id = p.doctor_id
GROUP BY d.name
HAVING COUNT(p.patient_id) > 3;
--q17
SELECT name AS patient_name_without_treatment 
FROM patients 
WHERE patient_id NOT IN (SELECT patient_id FROM treatments);
--q18
SELECT medication_name AS medicine_with_low_stock, quantity AS current_quantity 
FROM medication_stock 
WHERE quantity < (SELECT AVG(quantity) FROM medication_stock);
--q19
SELECT 
    d.name AS doctor_name, 
    p.name AS patient_name, 
    p.age AS patient_age,
    RANK() OVER (PARTITION BY d.doctor_id ORDER BY p.age ASC) AS age_rank
FROM doctors d
LEFT JOIN patients p ON d.doctor_id = p.doctor_id
WHERE p.patient_id IS NOT NULL;
--q20
WITH spec_max_age AS (
    SELECT 
        d.specialization, 
        MAX(p.age) AS max_patient_age
    FROM doctors d
    JOIN patients p ON d.doctor_id = p.doctor_id
    GROUP BY d.specialization
)
SELECT 
    sma.specialization AS doctor_specialization, 
    d.name AS doctor_with_oldest_patient, 
    p.name AS oldest_patient_name, 
    p.age AS patient_age
FROM spec_max_age sma
JOIN doctors d ON sma.specialization = d.specialization
JOIN patients p ON d.doctor_id = p.doctor_id
WHERE p.age = sma.max_patient_age;







