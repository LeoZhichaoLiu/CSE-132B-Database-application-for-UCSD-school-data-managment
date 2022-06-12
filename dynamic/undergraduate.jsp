<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>Undergraduate</title>
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


            <%
            // Check if an insertion is requested        
            String action = request.getParameter("action");
                    
            if (action != null && action.equals("insert")) {
              conn.setAutoCommit(false);
                
              PreparedStatement pstmt = conn.prepareStatement("INSERT INTO undergraduate VALUES (?, ?, ?, ?)");

              pstmt.setString(1, request.getParameter("id"));
              pstmt.setString(2, request.getParameter("college"));
              pstmt.setString(3, request.getParameter("major"));
              pstmt.setString(4, request.getParameter("minor"));
                                        
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
                      "UPDATE undergraduate SET college = ?, major = ?, " +
                      "minor = ? WHERE id = ?");
                  
                  pstmt.setString(1, request.getParameter("college"));
                  pstmt.setString(2, request.getParameter("major"));
                  pstmt.setString(3, request.getParameter("minor"));
                  pstmt.setString(4, request.getParameter("id"));
                  
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
                  
                  PreparedStatement pstmt = conn.prepareStatement("DELETE FROM undergraduate WHERE id = ?");
                  
                  pstmt.setString(1, request.getParameter("id"));
                  
                  int rowCount = pstmt.executeUpdate();
                  
                  conn.setAutoCommit(false);
                  conn.setAutoCommit(true);
              }
            %>

            <%-- statement --%>
            <%
              Statement statement = conn.createStatement();
              ResultSet rs = statement.executeQuery("SELECT * FROM undergraduate");
            %>

            <%-- presentation --%>
              <table>
                  <tr>
                      <th>id</th>
                      <th>college</th>
                      <th>major</th>
                      <th>minor</th>
                  </tr>

                  <tr>
                      <form action="undergraduate.jsp" method="get">
                          <input type="hidden" value="insert" name="action">
                          <%
                   			Statement statement2 = conn.createStatement();        
                   			ResultSet rs2 = statement2.executeQuery ("select * from Student" +
                   			                " where id not in ((select id from graduate) UNION" +
                   			                " (select id from undergraduate UNION (select id from ms_bs)))");
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
                          <th><div>
						 	 <br>
							<input type="radio" name="college" value="Muir" checked>Muir
							<br>
							<input type="radio" name="college" value="Revelle">Revelle
							<br>
							<input type="radio" name="college" value="Marshall">Marshall
							<br>
							<input type="radio" name="college" value="ERC">ERC
							<br>
							<input type="radio" name="college" value="Warren">Warren
							<br>
							<input type="radio" name="college" value="Sixth">Sixth
							<br>
							<input type="radio" name="college" value="Seventh">Seventh
							<br>
						  </div></th>
                          <th><input value="" name="major" size="15"></th>
                          <th><input value="" name="minor" size="15"></th>
                          <th><input type="submit" value="Insert"></th>
                      </form>
                  </tr>

            <%-- iteration --%>
            <%
              // Iterate over the ResultSet     
              while ( rs.next() ) {      
            %>

            <tr>
                <form action="undergraduate.jsp" method="get">
                    <input type="hidden" value="update" name="action">
                    <%
                   		Statement statement3 = conn.createStatement();        
                   		ResultSet rs3 = statement3.executeQuery ("select * from student"+
       			                " where id not in ((select id from graduate) UNION" +
       			                " (select id from undergraduate) UNION (select id from ms_bs))");
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
                    
			 		<td>
						<br>
						<input type="radio" name="college" value="Muir" <%=rs.getString("college").equals("Muir") ? "checked" : ""  %>  >Muir
						<br>
						<input type="radio" name="college" value="Revelle" <%=rs.getString("college").equals("Revelle") ? "checked" : ""  %>  >Revelle
						<br>
						<input type="radio" name="college" value="Marshall" <%=rs.getString("college").equals("Marshall") ? "checked" : ""  %>  >Marshall
						<br>
						<input type="radio" name="college" value="ERC" <%=rs.getString("college").equals("ERC") ? "checked" : ""  %>  >ERC
						<br>
						<input type="radio" name="college" value="Warren" <%=rs.getString("college").equals("Warren") ? "checked" : ""  %>  >Warren
						<br>
						<input type="radio" name="college" value="Sixth" <%=rs.getString("college").equals("Sixth") ? "checked" : ""  %>  >Sixth
						<br>
						<input type="radio" name="college" value="Seventh" <%=rs.getString("college").equals("Seventh") ? "checked" : ""  %>  >Seventh
						<br>
				    </td>
                    <td><input value="<%= rs.getString("major") %>" name="major"></td>
                    <td><input value="<%= rs.getString("minor") %>" name="minor"></td>
                    <td><input type="submit" value="Update"></td>
                </form>


                <form action="undergraduate.jsp" method="get">
                    <input type="hidden" value="delete" name="action">
                    <input type="hidden" value="<%= rs.getString("id") %>" name="id">
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