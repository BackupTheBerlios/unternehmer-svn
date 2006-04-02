import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

public class WelcomeServlet extends HttpServlet {

  public void doPost(HttpServletRequest request,
              HttpServletResponse response)
              throws ServletException, IOException {

	response.setContentType("text/xml");
	response.setHeader("Cache-Control", "no-cache");
	response.getWriter().write("valid"); 
   

   }
}
