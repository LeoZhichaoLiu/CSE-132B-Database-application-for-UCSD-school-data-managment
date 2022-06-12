<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>Course Enrollment</title>
</head>

<body>
  <jsp:include page="index.html" />
    <table>
        <tr>

            <td>
    
            <%
            try {
              // Load postgres Driver class file
              DriverManager.registerDriver(new org.postgresql.Driver());
    
              // Make a connection to the postgres datasource 
             //Connection conn = DriverManager.getConnection(
             //"jdbc:postgresql:trition?user=postgres&password=Djp7052!");
              Connection conn = DriverManager.getConnection("jdbc:postgresql:leo?user=leo");
            %>


            <%
            // Check if an insertion is requested        
            String action = request.getParameter("action");
                    
            if (action != null && action.equals("insert")) {
              conn.setAutoCommit(false);
              
              String class_info = request.getParameter("class_info");
              String course_name = class_info.split(" ")[0];
              int section_id =  Integer.parseInt(class_info.split(" ")[1]);
              String instructor = class_info.split(" ")[3];
              
              // Use trigger to set constraint based on enrollment limit. Cannot exceed the limits.
              PreparedStatement trigger_stmt = conn.prepareStatement(
            		  "CREATE OR REPLACE FUNCTION trigger_function() RETURNS TRIGGER AS $$ BEGIN " +
            		  "if ((select current_number from current_enrolled where course_name = new.course_name AND section_id = new.section_id) " +
            		  ">= (select enrollment_limit from current_enrolled where course_name = new.course_name AND section_id = new.section_id)) " +
            		  "then raise exception 'The enrollment seats are filled'; " + 
            		  "end if;" +
            		  "return new;" + 
            		  "end; $$ language plpgsql;" +
            		  "CREATE OR REPLACE TRIGGER enrolled_limit BEFORE INSERT ON course_enrollment FOR EACH ROW EXECUTE PROCEDURE trigger_function();"
             );
             
             trigger_stmt.executeUpdate();
         
            
              PreparedStatement pstmt = conn.prepareStatement(
               "INSERT INTO course_enrollment(id, course_name, section_id, units, instructor, grade) VALUES (?, ?, ?, ?, ?, ?)");
              
              pstmt.setString(1, request.getParameter("id"));
              pstmt.setString(2, course_name);
              pstmt.setInt(3, section_id);
              pstmt.setInt(4, Integer.parseInt(request.getParameter("units")));
              pstmt.setString(5, instructor);
              pstmt.setString(6, request.getParameter("grade"));

              pstmt.executeUpdate();
              
              pstmt = conn.prepareStatement( 
            		  "UPDATE current_enrolled SET current_number = current_number + 1" +
                      " WHERE course_name = ? AND section_id = ?"
              );
              
              pstmt.setString(1, course_name);
              pstmt.setInt(2, section_id);
              pstmt.executeUpdate();
              
              conn.setAutoCommit(false);
              conn.setAutoCommit(true);                   
            }
            %>

            <%-- update --%>
            <%
              // Check if an update is requested
              if (action != null && action.equals("update")) {

                  conn.setAutoCommit(false);

                  PreparedStatement pstmt = conn.prepareStatement(
                      "UPDATE course_enrollment SET id = ?, course_name = ?, " +
                      "section_id = ?, units = ?, instructor = ?, grade = ? WHERE unique_id = ?");
                  
                  
                  String class_info = request.getParameter("class_info");
                  String course_name = class_info.split(" ")[0];
                  String section_id = class_info.split(" ")[1];
                  String instructor = class_info.split(" ")[3];
                  
                  pstmt.setString(1, request.getParameter("id"));
                  pstmt.setString(2, course_name);
                  pstmt.setInt(3, Integer.parseInt(section_id));
                  pstmt.setInt(4, Integer.parseInt(request.getParameter("units")));
                  pstmt.setString(5, instructor);
                  pstmt.setString(6, request.getParameter("grade"));
                  pstmt.setInt(7, Integer.parseInt(request.getParameter("unique_id")));
                  
                  pstmt.executeUpdate();

                  conn.setAutoCommit(false);
                  conn.setAutoCommit(true);
              }
            %>

            <%-- delete --%>
            <%
              // Check if a delete is requested
              if (action != null && action.equals("delete")) {

                  conn.setAutoCommit(false);
                  
                  PreparedStatement pstmt = conn.prepareStatement(
                   "DELETE FROM course_enrollment WHERE unique_id = ?");
                  
               
                  pstmt.setInt(1, Integer.parseInt(request.getParameter("unique_id")));
                  
                  pstmt.executeUpdate();
                  
                  pstmt = conn.prepareStatement( 
                		  "UPDATE current_enrolled SET current_number = current_number - 1" +
                          " WHERE course_name = ? AND section_id = ?"
                  );
                  
                  pstmt.setString(1, request.getParameter("course_name"));
                  pstmt.setInt(2, Integer.parseInt(request.getParameter("section_id")));
                  pstmt.executeUpdate();
                            
                  conn.setAutoCommit(false);
                  conn.setAutoCommit(true);
              }
            %>

            <%-- statement --%>
            <%
              Statement statement = conn.createStatement();
              ResultSet rs = statement.executeQuery("SELECT * FROM course_enrollment");
            %>

            <%-- presentation --%>
              <table>
                  <tr>
                      <th>student id</th>
                      <th>class info</th>
                      <th>units taken</th>
                      <th>grade</th>
                  </tr>

                  <tr>
                      <form action="course_enrollment.jsp" method="get">
                          <input type="hidden" value="insert" name="action">
                          <%
                   			Statement statement2 = conn.createStatement();        
                   			ResultSet rs2 = statement2.executeQuery ("select * from Student");
                   		  %>
                   		  <th>
                   		  <select name="id">
                   			<%   while (rs2.next()) {   
                   				String student_id = rs2.getString("id");
                   			%>
  								<option value="<%= student_id%>"><%= student_id%></option>
  							<%  }  %>
						           </select>


                      	  </th>
                      	  <%
                   			 ResultSet rs4 = statement2.executeQuery ("select * from Class WHERE " +
                      	                                             "Year = 2022 AND Quarter = 'SP'");
                   		  %>
                   		  <th>

                   		  <select name="class_info">
                   		    <%   while (rs4.next()) {   
                   				   String course_name = rs4.getString("course_name");
                   				   int section_id = rs4.getInt("section_id");
                             String instructor = rs4.getString("instructor");
                   				   
                   				PreparedStatement p5 = conn.prepareStatement("select * from Course WHERE " +
                                        "Course_Name = ? ");
                             	p5.setString(1, course_name);
                             	ResultSet rs5 = p5.executeQuery();
                             	int min_unit = 0;
                             	int max_unit = 0;
                             	while (rs5.next()) {
                      	         	min_unit = rs5.getInt("min_units");
                      	         	max_unit = rs5.getInt("max_units");
                      	         }
                   				   
                   				String class_info = course_name + " " + section_id + " units:" + 
                   				         min_unit + "~" + max_unit  + " "  + instructor;
                   		    %>
  								<option value="<%= class_info%>"><%= class_info %></option>
  			                <%  }  %>
						  </select>
                      	  </th>
                      	  
                          <th><input value="" name="units" size="2"></th> 
                          
                          <th><div>
				       	  	 <br>
					  		 <input type="radio" name="grade" value="Letter">Letter
					   		 <br>
					   		 <input type="radio" name="grade" value="S/U" checked>S/U
						  </div></th>

                          <th><input type="submit" value="Insert"></th>
                      </form>
                  </tr>

            <%-- iteration --%>
            <%
              // Iterate over the ResultSet     
              while ( rs.next() ) {      
            %>

            <tr>
                <form action="course_enrollment.jsp" method="get">
                    <input type="hidden" value="update" name="action">
                    <input type="hidden" value="<%= rs.getInt("unique_id") %>" name="unique_id">
                    
                   	<%
                   		Statement statement3 = conn.createStatement();        
                   		ResultSet rs3 = statement3.executeQuery ("select * from student");
                 	%>
                  	<th>
                  	 		<select name="id">
                   		    <option value="<%= rs.getString("id") %>"> 
                   		         <%= rs.getString("id") %></option>
                   			<%   while (rs3.next()) {   
                   				 String student_id = rs3.getString("id");
                   			%>
  								<option value="<%= student_id%>"><%= student_id%></option>
  							<%  }  %>
						</select>
                   	</th>
                   	
                   	
                   	<%
                   	    ResultSet rs6 = statement2.executeQuery ("select * from Class WHERE " +
                      	                                             "Year = 2022 AND Quarter = 'SP'");
                   	%>
                   		<th>
                   		<select name="class_info">
                   		
                   		    <% 
                   				 String course_name = rs.getString("Course_Name");
                   				 int section_id = rs.getInt("Section_id");
                            String instructor = rs.getString("instructor");
                   				 
                   				PreparedStatement p5 = conn.prepareStatement("select * from Course WHERE " +
                                        "Course_Name = ? ");
                             	p5.setString(1, course_name);
                             	ResultSet rs5 = p5.executeQuery();
                             	int min_unit = 0;
                             	int max_unit = 0;
                             	while (rs5.next()) {
                      	         	min_unit = rs5.getInt("min_units");
                      	         	max_unit = rs5.getInt("max_units");
                      	         }
                   				   
                   				String class_info = course_name + " " + section_id +  " units:" + 
                   				         min_unit + "~" + max_unit + " "  + instructor;
                   				                   
                   			%>
                   			<option value="<%= class_info %>"> <%= class_info %></option>
                   		    <%   while (rs6.next()) {   
                   				   course_name = rs6.getString("course_name");
                   				   section_id = rs6.getInt("section_id");
                              instructor = rs6.getString("instructor");
                   				   
                   				p5 = conn.prepareStatement("select * from Course WHERE " +
                                        "Course_Name = ? ");
                             	p5.setString(1, course_name);
                             	rs5 = p5.executeQuery();
                             	min_unit = 0;
                             	max_unit = 0;
                             	while (rs5.next()) {
                      	         	min_unit = rs5.getInt("min_units");
                      	         	max_unit = rs5.getInt("max_units");
                      	         }
                   				   
                   				class_info = course_name + " " + section_id + " units:" + 
                   				         min_unit + "~" + max_unit + " " + instructor;
                   		    %>
  								<option value="<%= class_info%>"><%= class_info %></option>
  			                <%  }  %>
						</select>
                      </th> 
                   		  
                   		  
                    <td><input value="<%= rs.getString("units") %>" name="units"></td>
                    
                    <td>
					<br>
						<input type="radio" name="grade" value="Letter" <%=rs.getString("grade").equals("Letter") ? "checked" : ""  %>  >Letter
						<br>
						<input type="radio" name="grade" value="S/U" <%=rs.getString("grade").equals("S/U") ? "checked" : ""  %>  >S/U
						<br>
			     	</td>
			     
                    <td><input type="submit" value="Update"></td>
                </form>


                <form action="course_enrollment.jsp" method="get">
                    <input type="hidden" value="delete" name="action">
                    <input type="hidden" value="<%= rs.getInt("unique_id") %>" name="unique_id">
                     <input type="hidden" value="<%= rs.getString("course_name") %>" name="course_name">
                     <input type="hidden" value="<%= rs.getInt("section_id") %>" name="section_id">
                    <td><input type="submit" value="Delete"></td>
                </form>
            </tr>
            
            <%
              }
            %>
          </table>

            <%-- close connectivity --%>
            <%
              rs.close();
              statement.close();
              conn.close();
              } catch (SQLException sqle) {
                  out.println(sqle.getMessage());
              } catch (Exception e) {
                  out.println(e.getMessage());
              }
            %>
                
            </td>
        </tr>
    </table>
</body>
</html>