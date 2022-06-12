<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>Faculty</title>
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
               //Connection conn = DriverManager.getConnection("jdbc:postgresql:leo?user=leo");
                Connection conn = DriverManager.getConnection(
                      "jdbc:postgresql:leo?user=leo");
            %>



            <%-- insert --%>
            <%
            // Check if an insertion is requested        
            String action = request.getParameter("action");
                    
            if (action != null && action.equals("insert")) {
              conn.setAutoCommit(false);
                
              PreparedStatement pstmt = conn.prepareStatement("INSERT INTO faculty VALUES (?, ?, ?)");

              pstmt.setString(1, request.getParameter("name"));
              pstmt.setString(2, request.getParameter("title"));
              pstmt.setString(3, request.getParameter("department"));
                                        
              pstmt.executeUpdate();
              // conn.commit();
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
                      "UPDATE faculty SET title = ?, " + "department = ? WHERE name = ?");
                  pstmt.setString(1, request.getParameter("title"));
                  pstmt.setString(2, request.getParameter("department"));
                  pstmt.setString(3, request.getParameter("name"));

                  int rowCount = pstmt.executeUpdate();

                  // conn.commit();
                  conn.setAutoCommit(false);
                  conn.setAutoCommit(true);
              }
            %>

            <%-- delete --%>
            <%
              // Check if a delete is requested
              if (action != null && action.equals("delete")) {

                  conn.setAutoCommit(false);
                  
                  PreparedStatement pstmt = conn.prepareStatement("DELETE FROM faculty WHERE name = ?");
                  pstmt.setString(1, request.getParameter("name"));
                  int rowCount = pstmt.executeUpdate();
                  
                  // conn.commit();
                  conn.setAutoCommit(false);
                  conn.setAutoCommit(true);
              }
            %>

            <%-- statement --%>
            <%
              Statement statement = conn.createStatement();
              ResultSet rs = statement.executeQuery("SELECT * FROM faculty");
            %>

            <%-- presentation --%>
              <table>
                  <tr>
                      <th>name</th>
                      <th>title</th>
                      <th>department</th>
                  </tr>

                  <tr>
                      <form action="Faculty.jsp" method="get">
                          <input type="hidden" value="insert" name="action">
                          <th><input value="" name="name" size="15"></th>
                          <th><div>
						 	 <br>
							<input type="radio" name="title" value="Lecturer" checked>Lecturer
							<br>
							<input type="radio" name="title" value="Assistant_Professor">Assistant_Professor
							<br>
							<input type="radio" name="title" value="Associate_Professor">Associate_Professor
							<br>
							<input type="radio" name="title" value="Professor">Professor
							<br>
						  </div></th>
                          <%
                   				Statement statement2 = conn.createStatement();        
                   				ResultSet rs2 = statement2.executeQuery ("select * from department");
                  		  %>
                   		  <th>
                   				<select name="department">
                   				<%   while (rs2.next()) {   
                   				 	String department_name = rs2.getString("name");
                   				%>
  									<option value="<%= department_name%>"><%= department_name%></option>
  								<%  }  %>
							</select>
                   		  </th>
                          <th><input type="submit" value="Insert"></th>
                      </form>
                  </tr>

            <%-- iteration --%>
            <%
              // Iterate over the ResultSet     
              while ( rs.next() ) {      
            %>

            <tr>
                <form action="Faculty.jsp" method="get">
                    <input type="hidden" value="update" name="action">
                    <td><input value="<%= rs.getString("name") %>" name="name"></td>
                    <td>
						<br>
						<input type="radio" name="title" value="Lecturer" <%=rs.getString("title").equals("Lecturer") ? "checked" : ""  %>  >Lecturer
						<br>
						<input type="radio" name="title" value="Assistant_Professor" <%=rs.getString("title").equals("Assistant_Professor") ? "checked" : ""  %>  >Assistant_Professor
						<br>
						<input type="radio" name="title" value="Associate_Professor" <%=rs.getString("title").equals("Associate_Professor") ? "checked" : ""  %>  >Associate_Professor
						<br>
						<input type="radio" name="title" value="Professor" <%=rs.getString("title").equals("Professor") ? "checked" : ""  %>  >Professor
						<br>
				    </td>
                    <%
                   	Statement statement3 = conn.createStatement();        
                   	ResultSet rs3 = statement3.executeQuery ("select * from department");
                 	%>
                   <th>
                   		<select name="department">
                   		    <option value="<%= rs.getString("department") %>"> 
                   		         <%= rs.getString("department") %></option>
                   			<%   while (rs3.next()) {   
                   				 String department_name = rs3.getString("name");
                   			%>
  								<option value="<%= department_name%>"><%= department_name%></option>
  							<%  }  %>
						</select>
                   </th>
                    <td><input type="submit" value="Update"></td>
                </form>
                
                <form action="Faculty.jsp" method="get">
                    <input type="hidden" value="delete" name="action">
                    <input type="hidden" value="<%= rs.getString("name") %>" name="name">
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