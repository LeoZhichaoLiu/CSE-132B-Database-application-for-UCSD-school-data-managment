<%@ page language="java" import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<title>Graduate</title>
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
            String id;
            String department;
            Boolean is_MS;
            Boolean is_PhD_candidate;
            Boolean is_pre_candidacy;
            String major;

            if (action != null && action.equals("insert")) {
              conn.setAutoCommit(false);
              
              // graduate(  id, department, is_MS, is_PhD_candidate, is_pre_candidacy  ) 
              // MS( id, department )
              // PhD_candidate( id, department )
              // pre_candidacy( id, department )
              PreparedStatement pstmt1 = conn.prepareStatement("INSERT INTO graduate VALUES (?, ?, ?, ?, ?, ?)");
              PreparedStatement pstmt2 = conn.prepareStatement("INSERT INTO MS VALUES (?, ?, ?)");
              PreparedStatement pstmt3 = conn.prepareStatement("INSERT INTO PhD_candidate VALUES (?, ?)");
              PreparedStatement pstmt4 = conn.prepareStatement("INSERT INTO pre_candidacy VALUES (?, ?)");

              id = request.getParameter("id");
              department = request.getParameter("department");
              is_MS = Boolean.parseBoolean(request.getParameter("is_MS"));
              is_PhD_candidate = Boolean.parseBoolean(request.getParameter("is_PhD_candidate"));
              is_pre_candidacy = Boolean.parseBoolean(request.getParameter("is_pre_candidacy"));
              major = request.getParameter("major");

              pstmt1.setString(1, id);
              pstmt1.setString(2, department);
              pstmt1.setBoolean(3, is_MS);
              pstmt1.setBoolean(4, is_PhD_candidate);
              pstmt1.setBoolean(5, is_pre_candidacy); 
              pstmt1.setString(6, major); 
              pstmt1.executeUpdate();

              if(is_MS) {
                pstmt2.setString(1, id);
                pstmt2.setString(2, department);
                pstmt2.setString(3, major);
                pstmt2.executeUpdate();
              }

              if(is_PhD_candidate) {
                pstmt3.setString(1, id);
                pstmt3.setString(2, department);
                pstmt3.executeUpdate();
              }

              if(is_pre_candidacy) {
                pstmt4.setString(1, id);
                pstmt4.setString(2, department);
                pstmt4.executeUpdate();
              }

              conn.setAutoCommit(false);
              conn.setAutoCommit(true);                   
            }
            %>

            <%-- update --%>
            <%
              // Check if an update is requested
              if (action != null && action.equals("update")) {

                  conn.setAutoCommit(false);

              // graduate(  id, department, is_MS, is_PhD_candidate, is_pre_candidacy  ) 
              // MS( id, department )
              // PhD_candidate( id, department )
              // pre_candidacy( id, department )
                  PreparedStatement pstmt1 = conn.prepareStatement(
                      "UPDATE graduate SET department = ?,  is_MS = ?, " +
                      "is_PhD_candidate = ?, is_pre_candidacy = ?, major = ? WHERE id = ?");

                      PreparedStatement pstmt2 = conn.prepareStatement(
                      "UPDATE MS SET department = ?, major = ? WHERE id = ?");

                      PreparedStatement pstmt3 = conn.prepareStatement(
                      "UPDATE PhD_candidate SET department = ?, major = ? WHERE id = ?");

                      PreparedStatement pstmt4 = conn.prepareStatement(
                      "UPDATE pre_candidacy SET department = ? WHERE id = ?");
                      

                      // below if degree input changes
                      PreparedStatement pstmt5 = conn.prepareStatement(
                      "DELETE FROM MS WHERE id = ?");

                      PreparedStatement pstmt6 = conn.prepareStatement(
                      "DELETE FROM PhD_candidate WHERE id = ?");

                      PreparedStatement pstmt7 = conn.prepareStatement(
                      "DELETE FROM pre_candidacy WHERE id = ?");


                      PreparedStatement pstmt8 = conn.prepareStatement(
                        "INSERT INTO MS(id, department, major) SELECT ?,?,? WHERE NOT EXISTS (SELECT * FROM MS WHERE id = ?)");

                      PreparedStatement pstmt9 = conn.prepareStatement(
                        "INSERT INTO PhD_candidate(id, department) SELECT ?,? WHERE NOT EXISTS (SELECT * FROM PhD_candidate WHERE id = ?)");

                      PreparedStatement pstmt10 = conn.prepareStatement(
                        "INSERT INTO pre_candidacy(id, department) SELECT ?,? WHERE NOT EXISTS (SELECT * FROM pre_candidacy WHERE id = ?)");

                  id = request.getParameter("id");
                  department = request.getParameter("department");
                  is_MS = Boolean.parseBoolean(request.getParameter("is_MS"));
                  is_PhD_candidate = Boolean.parseBoolean(request.getParameter("is_PhD_candidate"));
                  is_pre_candidacy = Boolean.parseBoolean(request.getParameter("is_pre_candidacy"));
                  major = request.getParameter("major");
                  
                  pstmt1.setString(1, department);
                  pstmt1.setBoolean(2, is_MS);
                  pstmt1.setBoolean(3, is_PhD_candidate);
                  pstmt1.setBoolean(4, is_pre_candidacy); 
                  pstmt1.setString(5, major); 
                  pstmt1.setString(6, id);                 
                  pstmt1.executeUpdate();

              if(is_MS) {

            	pstmt2.setString(1, department);
            	pstmt2.setString(2, major);
                pstmt2.setString(3, id);
                pstmt2.executeUpdate();

                pstmt8.setString(1, id);
                pstmt8.setString(2, department);
                pstmt8.setString(3, major);
                pstmt8.setString(4, id);
                pstmt8.executeUpdate();

                // delete if exist 
                pstmt6.setString(1, id);         
                pstmt6.executeUpdate();
                pstmt7.setString(1, id);
                pstmt7.executeUpdate();
              }

              if(is_PhD_candidate) {

                pstmt3.setString(2, id);
                pstmt3.setString(1, department);
                pstmt3.executeUpdate();

                pstmt9.setString(1, id);
                pstmt9.setString(2, department);
                pstmt9.setString(3, id);
                pstmt9.executeUpdate();

                // delete if exist 
                pstmt5.setString(1, id);
                pstmt5.executeUpdate();
                pstmt7.setString(1, id);
                pstmt7.executeUpdate();
              }

              if(is_pre_candidacy) {
                pstmt4.setString(2, id);
                pstmt4.setString(1, department);
                pstmt4.executeUpdate();

                pstmt10.setString(1, id);
                pstmt10.setString(2, department);
                pstmt10.setString(3, id);
                pstmt10.executeUpdate();
                
                // delete if exist 
                pstmt5.setString(1, id);
                pstmt5.executeUpdate();
                pstmt6.setString(1, id);
                pstmt6.executeUpdate();
              }

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
                  
                  // since i use cascade on delete and on update, 
                  // i think corresponding row in MS/PhD will also update????
                  PreparedStatement pstmt = conn.prepareStatement("DELETE FROM graduate WHERE id = ?");
                  
                  pstmt.setString(1, request.getParameter("id"));
                  
                  int rowCount = pstmt.executeUpdate();

                  conn.setAutoCommit(false);
                  conn.setAutoCommit(true);
              }
            %>

            <%-- statement --%>
            <%
              Statement statement = conn.createStatement();
              ResultSet rs = statement.executeQuery("SELECT * FROM graduate");
            %>

            <%-- presentation --%>
              <table>
                  <tr>
                      <th>id</th>
                      <th>department</th>
                      <th>is_MS</th>
                      <th>is_PhD_candidate</th>
                      <th>is_pre_candidacy</th>
                      <th>major</th>
                  </tr>

                  <tr>
                      <form action="graduate.jsp" method="get">
                          <input type="hidden" value="insert" name="action">
                          <%
                   			Statement statement2 = conn.createStatement();        
                   			ResultSet rs2 = statement2.executeQuery ("select * from Student" +
           			                " where id not in ((select id from graduate) UNION" +
           			                " (select id from undergraduate) UNION (select id from ms_bs))");
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
                   				ResultSet rs4 = statement4.executeQuery ("select * from department");
                  		   %>
                   		   <th>
                   				<select name="department">
                   				<%   while (rs4.next()) {   
                   				 	String department_name = rs4.getString("name");
                   				%>
  									<option value="<%= department_name%>"><%= department_name%></option>
  								<%  }  %>
							</select>
                   		  </th>
                          <th><div>
				       	  	 <br>
					  		 <input type="radio" name="is_MS" value="True">Yes
					   		 <br>
					   		 <input type="radio" name="is_MS" value="False" checked>No
						  </div></th>
						  <th><div>
				       	  	 <br>
					  		 <input type="radio" name="is_PhD_candidate" value="True">Yes
					   		 <br>
					   		 <input type="radio" name="is_PhD_candidate" value="False" checked>No
						  </div></th>
						  <th><div>
				       	  	 <br>
					  		 <input type="radio" name="is_pre_candidacy" value="True">Yes
					   		 <br>
					   		 <input type="radio" name="is_pre_candidacy" value="False" checked>No
						  </div></th>
						   <th><input value="" name="major" size="15"></th>
                          <th><input type="submit" value="Insert"></th>
                      </form>
                  </tr>

            <%-- iteration --%>
            <%
              // Iterate over the ResultSet     
              while ( rs.next() ) {      
            %>

            <tr>
                <form action="graduate.jsp" method="get">
                    <input type="hidden" value="update" name="action">
                    <%
                   		Statement statement3 = conn.createStatement();        
                   		ResultSet rs3 = statement3.executeQuery ("select * from Student" +
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
                    <%
                   		Statement statement5 = conn.createStatement();        
                   		ResultSet rs5 = statement5.executeQuery ("select * from department");
                 	%>
                   <th>
                   		<select name="department">
                   		    <option value="<%= rs.getString("department") %>"> 
                   		         <%= rs.getString("department") %></option>
                   			<%   while (rs5.next()) {   
                   				 String department_name = rs5.getString("name");
                   			%>
  								<option value="<%= department_name%>"><%= department_name%></option>
  							<%  }  %>
						</select>
                    </th>
                    <td>
						<br>
						<input type="radio" name="is_MS" value="True"  <%=rs.getBoolean("is_MS") == true ? "checked" : ""  %>  >Yes
						<br>
						<input type="radio" name="is_MS" value="False" <%=rs.getBoolean("is_MS") == false ? "checked" : ""  %>  >No
						<br>
			    	</td>
			    	<td>
						<br>
						<input type="radio" name="is_PhD_candidate" value="True"  <%=rs.getBoolean("is_PhD_candidate") == true ? "checked" : ""  %>  >Yes
						<br>
						<input type="radio" name="is_PhD_candidate" value="False" <%=rs.getBoolean("is_PhD_candidate") == false ? "checked" : ""  %>  >No
						<br>
			    	</td>
			    	<td>
						<br>
						<input type="radio" name="is_pre_candidacy" value="True"  <%=rs.getBoolean("is_pre_candidacy") == true ? "checked" : ""  %>  >Yes
						<br>
						<input type="radio" name="is_pre_candidacy" value="False" <%=rs.getBoolean("is_pre_candidacy") == false ? "checked" : ""  %>  >No
						<br>
			    	</td>
			    	 <td><input value="<%= rs.getString("major") %>" name="major"></td>
                    <td><input type="submit" value="Update"></td>
                </form>


                <form action="graduate.jsp" method="get">
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