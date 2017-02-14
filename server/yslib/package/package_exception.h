#ifndef _PACKAGE_EXCEPTION_H_
#define _PACKAGE_EXCEPTION_H_


class package_exception_t: public exception
{
public:
    explicit package_exception_t(const char* err_):m_err(err_){}
    ~package_exception_t() throw (){}

    const char* what() const throw (){return m_err.c_str();}
private:
    string m_err;
};

#endif
