
public class WelcomeServlet extends HttpServlet {

	response = ServletResponse;
	response.setContentType("text/xml");
	response.setHeader("Cache-Control", "no-cache");
	response.write("valid"); 
   
}
