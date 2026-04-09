import mysql.connector


class AadaiDB:
    def get_db(self):
        db = mysql.connector.connect(
            host='localhost',
            user='root',
            password='Vicky@21',
            database='Aadai'
        )
        return db

    # Insert

    def add_customer(self):
        db = self.get_db()
        cursor = db.cursor()
        try:

            name = input('Enter Name: ').strip().title()
            email = input('Enter email:').strip().lower()
            phone = input('Enter Phone number:').strip()
            city = input('Enter city: ').strip().title()

            qry = 'Insert INTO CUSTOMERS (name,email,phone,city) VALUES (%s,%s,%s,%s)'
            cursor.execute(qry, (name, email, phone, city))
            db.commit()

            print('Customer Details added successfully')

        except Exception as e:
            print('Error:', e)

        finally:
            cursor.close()
            db.close()

    def add_brand(self):
        db = self.get_db()
        cursor = db.cursor()
        try:
            brand = input('Enter brand name:').strip().title()
            cursor.execute("INSERT INTO brands(brand_name) VALUES(%s)", (brand,))
            db.commit()
            print("Brand Added Successfully")

        except Exception as e:
            print(" Error:", e)

        finally:
            cursor.close()
            db.close()

    def add_category(self):
        db = self.get_db()
        cursor = db.cursor()

        try:
            cat = input("Enter category name: ")
            cursor.execute("INSERT INTO categories(category_name) VALUES(%s)", (cat,))
            db.commit()
            print("Category Added Successfully")
        except Exception as e:
            print("Error:", e)

        finally:
            cursor.close()
            db.close()

    def add_supplier(self):
        db = self.get_db()
        cursor = db.cursor()
        try:
            name = input("Supplier name: ").strip().title()
            contact = input("Contact: ").strip()
            city = input("City: ").strip().title()

            cursor.execute("INSERT INTO suppliers(supplier_name,contact,city) VALUES(%s,%s,%s)",
                           (name, contact, city)
                           )
            db.commit()
            print("Supplier Added Successfully")

        except Exception as e:
            print("Error:", e)

        finally:
            cursor.close()
            db.close()

    def add_product(self):
        db = self.get_db()
        cursor = db.cursor()
        try:
            name = input("Product name: ").strip().title()
            price = float(input("Price: "))
            size = input("Size (S/M/L/XL): ").strip()
            color = input("Color: ").strip()
            stock = int(input("Initial stock: "))
            category_id = int(input("Category ID: "))
            brand_id = int(input("Brand ID: "))

            query = (' INSERT INTO products(product_name,price,size,color,stock_qty,category_id,brand_id)'
                     'VALUES(%s,%s,%s,%s,%s,%s,%s)')

            cursor.execute(query, (name, price, size, color, stock, category_id, brand_id))
            db.commit()

            print("Product Added Successfully")

        except Exception as e:
            print("Error:", e)

        finally:
            cursor.close()
            db.close()

    def add_purchase(self):
        db = self.get_db()
        cursor = db.cursor()
        try:
            supplier_id = int(input("Supplier ID: "))

            cursor.execute(
                "INSERT INTO purchases(supplier_id,total_amount) VALUES(%s,%s)",
                (supplier_id, 0)
            )
            db.commit()

            purchase_id = cursor.lastrowid
            total_amount = 0

            while True:
                product_id = int(input("Product ID: "))
                qty = int(input("Quantity: "))
                cost = float(input("Cost price: "))

                line_total = qty * cost
                total_amount += line_total

                # insert purchase item
                cursor.execute(
                    "INSERT INTO purchase_items(purchase_id,product_id,quantity,cost_price) VALUES(%s,%s,%s,%s)",
                    (purchase_id, product_id, qty, cost)
                )

                # UPDATE STOCK (INCREASE)
                cursor.execute(
                    "UPDATE products SET stock_qty = stock_qty + %s WHERE product_id = %s",
                    (qty, product_id)
                )

                db.commit()

                more = input("Add more items? (y/n): ")
                if more.lower() != 'y':
                    break

            # update total
            cursor.execute(
                "UPDATE purchases SET total_amount=%s WHERE purchase_id=%s",
                (total_amount, purchase_id)
            )
            db.commit()

            print("Purchase Completed Successfully")

        except Exception as e:
            print("Error:", e)

        finally:
            cursor.close()
            db.close()

    def add_order(self):
        db = self.get_db()
        cursor = db.cursor()
        try:
            customer_id = int(input("Customer ID: "))

            # create order
            cursor.execute(
                "INSERT INTO orders(customer_id,total_amount) VALUES(%s,%s)",
                (customer_id, 0)
            )
            db.commit()

            order_id = cursor.lastrowid
            total_amount = 0

            while True:
                product_id = int(input("Product ID: "))
                qty = int(input("Quantity: "))

                # get product details
                cursor.execute(
                    "SELECT product_name, price, stock_qty FROM products WHERE product_id=%s",
                    (product_id,)
                )
                result = cursor.fetchone()

                if not result:
                    print("Product not found")
                    continue

                name, price, stock = result

                if qty > stock:
                    print("Not enough stock")
                    continue

                line_total = qty * price
                total_amount += line_total

                # insert order item
                cursor.execute(
                    "INSERT INTO order_items(order_id,product_id,quantity,price) VALUES(%s,%s,%s,%s)",
                    (order_id, product_id, qty, price)
                )

                #  reduce stock
                cursor.execute(
                    "UPDATE products SET stock_qty = stock_qty - %s WHERE product_id=%s",
                    (qty, product_id)
                )

                db.commit()

                more = input("Add more items? (y/n): ")
                if more.lower() != 'y':
                    break

            # update total
            cursor.execute(
                "UPDATE orders SET total_amount=%s WHERE order_id=%s",
                (total_amount, order_id)
            )

            # payment
            method = input("Payment Method (Cash/UPI/Card): ")

            cursor.execute(
                "INSERT INTO payments(order_id,payment_method,payment_status,amount) VALUES(%s,%s,%s,%s)",
                (order_id, method, "PAID", total_amount)
            )

            db.commit()

            print("Order Placed Successfully")

            # print bill
            self.print_bill(order_id)

        except Exception as e:
            print("Error:", e)

        finally:
            cursor.close()
            db.close()

    def print_bill(self, order_id):
        db = self.get_db()
        cursor = db.cursor()
        print("\n=========== BILL ===========")

        cursor.execute("""
            SELECT o.order_id, c.name, o.order_date, o.total_amount
            FROM orders o
            JOIN customers c ON o.customer_id = c.customer_id
            WHERE o.order_id = %s
        """, (order_id,))
        order = cursor.fetchone()

        print(f"Order ID : {order[0]}")
        print(f"Customer : {order[1]}")
        print(f"Date     : {order[2]}")
        print("----------------------------")

        cursor.execute("""
            SELECT p.product_name, oi.quantity, oi.price
            FROM order_items oi
            JOIN products p ON oi.product_id = p.product_id
            WHERE oi.order_id = %s
        """, (order_id,))

        for item in cursor.fetchall():
            name, qty, price = item
            print(f"{name} x{qty} = ₹{qty * price}")

        print("----------------------------")
        print(f"TOTAL = ₹{order[3]}")
        print("======= THANK YOU =======\n")
        print("=====AADAI CLOTHING======")
        print(" Your style our passion ")

    # VIEW FUNCTION
    def view_customers(self):
        db = self.get_db()
        cursor = db.cursor()
        cursor.execute("SELECT * FROM customers")
        for x in cursor.fetchall():
            print(x)

    def view_products(self):
        db = self.get_db()
        cursor = db.cursor()
        cursor.execute("SELECT product_id,product_name,price,stock_qty FROM products")
        for x in cursor.fetchall():
            print(x)

    def view_stock(self):
        db = self.get_db()
        cursor = db.cursor()
        cursor.execute("SELECT product_id,product_name,stock_qty,price FROM products")
        for x in cursor.fetchall():
            print(x)

    def view_brands(self):
        db = self.get_db()
        cursor = db.cursor()
        cursor.execute("SELECT brand_id,brand_name FROM brands")
        for x in cursor.fetchall():
            print(x)

    def view_order_details(self):
        db = self.get_db()
        cursor = db.cursor()
        cursor.execute("""SELECT 
                                  o.order_id,
                                  c.name AS customer,
                                  p.product_name,
                                  oi.price,
                                  oi.quantity,
                                  (oi.quantity * oi.price) AS total
                               FROM orders o
                               JOIN customers c ON o.customer_id = c.customer_id
                               JOIN order_items oi ON o.order_id = oi.order_id
                               JOIN products p ON oi.product_id = p.product_id""")
        for x in cursor.fetchall():
            print(x)


# MENU

def menu():
    app = AadaiDB()

    while True:
        print("====== AADAI CLOTHING STORE ======")
        print("1. Add Customer")
        print("2. Add Brand")
        print("3. Add Category")
        print("4. Add Supplier")
        print("5. Add Product")
        print("6. Add Purchase (Stock In)")
        print("7. Add Order (Stock Out)")
        print("8. View Customers")
        print("9. View Brands")
        print("10.View Products")
        print("11.View Stock")
        print("12.View Order_details")
        print("13.Exit")

        choice = input("Enter your choice: ")

        if choice == "1":
            app.add_customer()
        elif choice == "2":
            app.add_brand()
        elif choice == "3":
            app.add_category()
        elif choice == "4":
            app.add_supplier()
        elif choice == "5":
            app.add_product()
        elif choice == "6":
            app.add_purchase()
        elif choice == "7":
            app.add_order()
        elif choice == "8":
            app.view_customers()
        elif choice == "9":
            app.view_brands()
        elif choice == "10":
            app.view_products()
        elif choice == "11":
            print("(Product_id,Product_name,Qty,Price)")
            app.view_stock()
        elif choice == "12":
            print("(Order_id,Name,Product_Name,Price,Qty,Amount)")
            app.view_order_details()
        elif choice == "13":
            print("Exiting...")
            print("DB closed")
            break
        else:
            print("Invalid choice")


menu()
