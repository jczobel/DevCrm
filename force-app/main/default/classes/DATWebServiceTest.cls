@RestResource(urlMapping='/HelloWorld/v1/*')


global class DATWebServiceTest {
@HttpGet
    webservice static string sayHI() {
        return 'Hello World!';
    }
}