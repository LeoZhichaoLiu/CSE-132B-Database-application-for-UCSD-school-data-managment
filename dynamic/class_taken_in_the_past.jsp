<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>Class Taken in the Past</title>
</head>


<body>
	<jsp:include page="index.html" />
	<table>
	<tr>
	<td>

    <%
    try {
        DriverManager.registerDriver(new org.postgresql.Driver());
    
      
        //Connection conn = DriverManager.getConnection(
        //       "jdbc:postgresql:trition?user=postgres&password=Djp7052!");
        Connection conn = DriverManager.getConnection("jdbc:postgresql:leo?user=leo");
        
        
        
        String action = request.getParameter("action");
        
        // Insertion Code
        if (action != null && action.equals("insert")) {
        	
            conn.setAutoCommit(false);
            
            // enrolled( id, year, quarter, course_name, section_id, grade)
            PreparedStatement stmt_class = conn.prepareStatement(
                "INSERT INTO class_taken_in_the_past(id, year, quarter, course_title, section_id, grade, units, instructor)" +
            								" VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
            
            String class_info = request.getParameter("class_info");
            String[] id_array = class_info.split(" ");
            
            stmt_class.setString(1, request.getParameter("id"));
            stmt_class.setInt(2, Integer.parseInt(id_array[2]));
            stmt_class.setString(3, id_array[3]);
            stmt_class.setString(4, id_array[0]);
            stmt_class.setInt(5, Integer.parseInt(id_array[1]));
            stmt_class.setString(6, request.getParameter("grade"));
            stmt_class.setInt(7, Integer.parseInt(request.getParameter("units")));
            stmt_class.setString(8, id_array[4]);
            
            int rowCount = stmt_class.executeUpdate();
            conn.commit();
            conn.setAutoCommit(true);
        }
        
        // Update Code
        if (action != null && action.equals("update")) {
        	
            conn.setAutoCommit(false);

            // class_taken_in_the_past(unique_id, id, year, quarter, course_name, section_id, grade, units, instructor )
            PreparedStatement stmt_class = conn.prepareStatement(
                "UPDATE class_taken_in_the_past SET id = ?, year = ?, quarter = ?, course_title = ?, " + 
                "section_id = ?, grade = ?, units = ?, instructor = ? WHERE unique_id = ?");
            
            String class_info = request.getParameter("class_info");
            String[] id_array = class_info.split(" ");
            
            stmt_class.setString(1, request.getParameter("id"));
            stmt_class.setInt(2, Integer.parseInt(id_array[2]));
            stmt_class.setString(3, id_array[3]);
            stmt_class.setString(4, id_array[0]);
            
            stmt_class.setInt(5, Integer.parseInt(id_array[1]));
            stmt_class.setString(6, request.getParameter("grade"));

            stmt_class.setInt(7, Integer.parseInt(request.getParameter("units")));
            stmt_class.setString(8, id_array[4]);
            stmt_class.setInt(9, Integer.parseInt(request.getParameter("unique_id")));
            
            
            int rowCount = stmt_class.executeUpdate();
            conn.commit();
            conn.setAutoCommit(true);
        }
        
        
        // Delete Code
        if (action != null && action.equals("delete")) {
            conn.setAutoCommit(false);
            
            PreparedStatement stmt_class = conn.prepareStatement(
            	"DELETE FROM class_taken_in_the_past WHERE unique_id = ?");
            
            stmt_class.setInt(1, Integer.parseInt(request.getParameter("unique_id")));
            
            stmt_class.executeUpdate();
            conn.commit();
            conn.setAutoCommit(true);
        }
    %>
    
     
     <%      
           Statement statement = conn.createStatement();        
           ResultSet rs = statement.executeQuery ("SELECT * FROM class_taken_in_the_past");
           
     %>     

            <%-- presentation --%>
              <table>
                  <tr>
                      <th>student id</th>
                      <th>Class_Info</th>
                      <th>grade</th>
                      <th>units taken</th>
                  </tr>

                  <tr>
                      <form action="class_taken_in_the_past.jsp" method="get">
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
                   	   			statement2 = conn.createStatement();        
                       			rs2 = statement2.executeQuery ("select * from class except select * from class where Year = 2022 AND Quarter = 'SP'");
                    		%>
                  			 <th>
                   			<select name="class_info">
                   			<%   while (rs2.next()) {   
                   				 String course_name = rs2.getString("Course_Name");
                   				 int section_id = rs2.getInt("Section_id");
                   				 int course_year = rs2.getInt("Year");
                   				 String course_quarter = rs2.getString("Quarter");
                          String instructor = rs2.getString("instructor");
                   				 
                   				 String course_id = course_name + " " + section_id + " " + 
                   				                    course_year + " " + course_quarter + " " + instructor;	 
                   			%>
  								<option value="<%= course_id%>"><%= course_id%></option>
  							<%  }  %>
							</select>
                   			</th>


     					<th><div>
        			  <input type="radio" name="grade" value="A+">A+	 
					   <input type="radio" name="grade" value="A">A
					   <input type="radio" name="grade" value="A-">A-
					   <input type="radio" name="grade" value="B+">B+
					   <input type="radio" name="grade" value="B">B
					   <input type="radio" name="grade" value="B-">B-
					   <input type="radio" name="grade" value="C+">C+
					   <input type="radio" name="grade" value="C">C
					   <input type="radio" name="grade" value="C-">C-
					   <input type="radio" name="grade" value="D+">D+
					   <input type="radio" name="grade" value="D">D
					   <input type="radio" name="grade" value="D-">D-
					   <input type="radio" name="grade" value="F">F
					   <input type="radio" name="grade" value="G">G
             <input type="radio" name="grade" value="S">S
             <input type="radio" name="grade" value="U">U
             <input type="radio" name="grade" value="IN">IN
				       </div></th>  
               <th><input value="" name="units" size="10"></th>        
                          
                        <th><input type="submit" value="Insert"></th>
                      </form>
                  </tr>

            <%-- iteration --%>
            
            
            
            <%
              // Iterate over the ResultSet     
              while ( rs.next() ) {      
            %>

            <tr>
                <form action="class_taken_in_the_past.jsp" method="get">
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
                   	   statement3 = conn.createStatement();        
                       rs3 = statement3.executeQuery ("select * from class except select * from class where Year = 2022 AND Quarter = 'SP'");
                    %>
                   <th>
                   		<select name="class_info">
                   		
                   			<% 
                   				 String course_name2 = rs.getString("Course_Title");
                   				 int section_id2 = rs.getInt("Section_id");
                   				 int course_year2 = rs.getInt("Year");
                   				 String course_quarter2 = rs.getString("Quarter");
                          String instructor2 = rs.getString("instructor");

                   				 String course_id2 = course_name2 + " " + section_id2 + " " + 
                   				                    course_year2 + " " + course_quarter2 + " " + instructor2;
                   			%>
                   			<option value="<%= course_id2 %>"> <%= course_id2 %></option>
        
                   			<%   while (rs3.next()) {   
                   				
                   				 String course_name = rs3.getString("Course_Name");
                   				 int section_id = rs3.getInt("Section_id");
                   				 int course_year = rs3.getInt("Year");
                   				 String course_quarter = rs3.getString("Quarter");
                            String instructor = rs3.getString("instructor");
                   				 
                   				 String course_id = course_name + " " + section_id + " " + 
                   				                    course_year + " " + course_quarter + " " + instructor;
                   			%>
  								<option value="<%= course_id%>"><%= course_id%></option>
  							<%  }  %>
						</select>
                   </th>
                   
                    
                    <td>
					<br>
						<input type="radio" name="grade" value="A+" <%=rs.getString("grade").equals("A+") ? "checked" : ""  %>  >A+
						<input type="radio" name="grade" value="A" <%=rs.getString("grade").equals("A") ? "checked" : ""  %>  >A
						<input type="radio" name="grade" value="A-" <%=rs.getString("grade").equals("A-") ? "checked" : ""  %>  >A-
						<input type="radio" name="grade" value="B+" <%=rs.getString("grade").equals("B+") ? "checked" : ""  %>  >B+
						<input type="radio" name="grade" value="B" <%=rs.getString("grade").equals("B") ? "checked" : ""  %>  >B
						<input type="radio" name="grade" value="B-" <%=rs.getString("grade").equals("B-") ? "checked" : ""  %>  >B-
						<input type="radio" name="grade" value="C+" <%=rs.getString("grade").equals("C+") ? "checked" : ""  %>  >C+
						<input type="radio" name="grade" value="C" <%=rs.getString("grade").equals("C") ? "checked" : ""  %>  >C
						<input type="radio" name="grade" value="C-" <%=rs.getString("grade").equals("C-") ? "checked" : ""  %>  >C-
						<input type="radio" name="grade" value="D+" <%=rs.getString("grade").equals("D+") ? "checked" : ""  %>  >D+
						<input type="radio" name="grade" value="D" <%=rs.getString("grade").equals("D") ? "checked" : ""  %>  >D
						<input type="radio" name="grade" value="D-" <%=rs.getString("grade").equals("D-") ? "checked" : ""  %>  >D-
						<input type="radio" name="grade" value="F" <%=rs.getString("grade").equals("F") ? "checked" : ""  %>  >F
			      <input type="radio" name="grade" value="G" <%=rs.getString("grade").equals("G") ? "checked" : ""  %>  >G
            <input type="radio" name="grade" value="S" <%=rs.getString("grade").equals("S") ? "checked" : ""  %>  >S
            <input type="radio" name="grade" value="U" <%=rs.getString("grade").equals("U") ? "checked" : ""  %>  >U
            <input type="radio" name="grade" value="IN" <%=rs.getString("grade").equals("IN") ? "checked" : ""  %>  >IN
			      </td>
            
            <td><input value="<%= rs.getInt("units") %>" name="units"></td>

                  <td><input type="submit" value="Update"></td>
                </form>


                <form action="class_taken_in_the_past.jsp" method="get">
                    <input type="hidden" value="delete" name="action">
                    <input type="hidden" value="<%= rs.getInt("unique_id") %>" name="unique_id">
                    <td><input type="submit" value="Delete"></td>
                </form>
            </tr>
            
            <%
              }
            %>
          </table>
     
     <%
           rs.close();
           statement.close();
           conn.close();
           
      } catch (SQLException e1) {
    	  throw new RuntimeException("SQL Exception!", e1); 
    	  
      } catch (Exception e2) {
    	  throw new RuntimeException("Exception!", e2); 
      }
      %>
      
     </td>
     </tr>
     </table>

</body>
</html>