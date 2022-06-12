<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>Advisor Submission</title>
</head>

<body>
<jsp:include page="index.html" />
    <table>
        <tr>
            <td>

            <%-- Set the scripting language to Java and --%>
            <%-- Import the java.sql package --%>
            <%@ page language="java" import="java.sql.*" %>
    


            <%-- open connectivity --%>
            <%
                try {
                    // Load postgres Driver class file
                    DriverManager.registerDriver(new org.postgresql.Driver());
    
                    // Make a connection to the postgres datasource 
                    Connection conn = DriverManager.getConnection("jdbc:postgresql:leo?user=leo");
                     //Connection conn = DriverManager.getConnection(
                //"jdbc:postgresql:trition?user=postgres&password=Djp7052!");
            %>



            <%-- insert --%>
            <%
            // Check if an insertion is requested        
            String action = request.getParameter("action");
                    
            if (action != null && action.equals("insert")) {
              conn.setAutoCommit(false);
 
              PreparedStatement pstmt = conn.prepareStatement(
               "INSERT INTO advisor(id, name) VALUES (?, ?)");

              // ignore unique_key
              pstmt.setString(1, request.getParameter("id"));
              pstmt.setString(2, request.getParameter("name"));
                                        
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
                      "UPDATE advisor SET name = ? WHERE unique_id = ?");
                  
                  pstmt.setString(1, request.getParameter("name"));
                  pstmt.setInt(2, Integer.parseInt(request.getParameter("unique_id")));
                 
                  int rowCount = pstmt.executeUpdate();

                  conn.setAutoCommit(false);
                  conn.setAutoCommit(true);
              }
            %>

            <%-- delete --%>
            <%
              // Check if a delete is requested
              if (action != null && action.equals("delete")) {

                  conn.setAutoCommit(false);
                  
                  PreparedStatement pstmt = conn.prepareStatement("DELETE FROM advisor WHERE unique_id = ?");
                  pstmt.setInt(1, Integer.parseInt(request.getParameter("unique_id")));
                  int rowCount = pstmt.executeUpdate();
                  
                  conn.setAutoCommit(false);
                  conn.setAutoCommit(true);
              }
            %>

            <%-- statement --%>
            <%
              Statement statement = conn.createStatement();
              ResultSet rs = statement.executeQuery("SELECT * FROM advisor");
            %>

            <%-- presentation --%>
              <table>
                  <tr>
                      <th>id</th>
                      <th>name</th>
                  </tr>

                  <tr>
                      <form action="advisor_submission.jsp" method="get">
                          <input type="hidden" value="insert" name="action">
                          <%
                   			Statement statement2 = conn.createStatement();        
                   			ResultSet rs2 = statement2.executeQuery ("select * from phd_candidate");
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
                   				Statement statement4 = conn.createStatement();        
                   				ResultSet rs4 = statement4.executeQuery ("select * from faculty");
                  		  %>
                   		  <th>
                   				<select name="name">
                   				<%   while (rs4.next()) {   
                   				 	String faculty_name = rs4.getString("name");
                   				%>
  									<option value="<%= faculty_name %>"><%= faculty_name %></option>
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
                <form action="advisor_submission.jsp" method="get">
                    <input type="hidden" value="update" name="action">
                    <input type="hidden" value="<%= rs.getInt("unique_id")%>" name="unique_id">
                    <%
                   		Statement statement3 = conn.createStatement();        
                   		ResultSet rs3 = statement3.executeQuery ("select * from graduate where is_phd_candidate = true");
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
                   	Statement statement5 = conn.createStatement();        
                   	ResultSet rs5 = statement5.executeQuery ("select * from faculty");
                 	%>
                   <th>
                   		<select name="name">
                   		    <option value="<%= rs.getString("name") %>"> 
                   		         <%= rs.getString("name") %></option>
                   			<%   while (rs5.next()) {   
                   				 String faculty_name = rs5.getString("name");
                   			%>
  								<option value="<%= faculty_name%>"><%= faculty_name%></option>
  							<%  }  %>
						</select>
                   </th>
                   
                    <td><input type="submit" value="Update"></td>
                </form>

                <form action="advisor_submission.jsp" method="get">
                    <input type="hidden" value="delete" name="action">
                    <input type="hidden" value="<%= rs.getInt("unique_id")%>" name="unique_id">
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