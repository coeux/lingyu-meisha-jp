#ifndef _sc_maxid_h_
#define _sc_maxid_h_

struct sc_maxid_t
{
    int maxid = 0;
    
    int  newid()
    {
        return (++maxid);
    }

    void update(int id_)
    {
        if (maxid < id_)
            maxid = id_;
    }
};

#endif
