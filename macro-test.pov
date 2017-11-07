#version 3.7;
global_settings{ assumed_gamma 1 }
#default{ finish{ ambient 0.1 diffuse 0.9 }} 
#include "colors.inc"
#include "textures.inc"
#include "glass.inc"
#include "metals.inc"
#include "golds.inc"
#include "stones.inc"
#include "woods.inc"
#include "shapes.inc"
#include "shapes2.inc"  
#include "shapes3.inc"
#include "functions.inc"
#include "math.inc"
#include "transforms.inc"    
//#local i=1*clock;        //str(1*clock,0,0)
#include concat("./render-includes/pov-ini-",str(1*clock,0,0),".pov")  
#include "predefined_type.inc.pov"    
#declare Voltage_vs_Li=3.0-Voltage_vs_PZC;
// set viewer's position in the scene 

//debug concat ( " wmt = ",str(wmt_array[i_type_mol],0,3), "\n"  )

camera {  perspective 
// (---camera types---)
//  perspective (default) | orthographic | fisheye |
//  ultra_wide_angle | omnimax | panoramic | cylinder 1 | spherical

  location  <0.0, -130.0, 0.0>   // position of camera <X,Y,Z>
 // direction 2.0*z              // which way are we looking <X,Y,Z> & zoom
//  sky       y                // for tilting the camera
//  up        y                  // which way is +up <X,Y,Z> (aspect ratio with x)
//  right x*image_width/image_height
                               // which way is +right <X,Y,Z> (aspect ratio with y)
  look_at   <0.0, 00.0,  0.0>   // point center of view at this point <X,Y,Z>

} 
light_source {  <1000, -1000, -1000> color White } 

light_source {  <000, -1000, 1000> color White   }
/*
light_source {
    <-10, -400, -10>
    color White
    area_light <-100, 0, 0>, <0, 0, 200>, 15, 15
    adaptive 1
    jitter
  }
 */   
  /*
light_source {
    <-80,-400,10>
    color White
    spotlight
    radius 15
    falloff 18
    tightness 10
    area_light <100, 0, 0>, <0, 0, 100>, 200, 200
    adaptive 1
    jitter
    point_at <-100, 0, 0>
  }
  
  light_source {
    <-210, -400, 10>
    color Blue
    spotlight
    radius 12
    falloff 14
    tightness 10
    area_light <-200, 0, 0>, <0, 0, 00>, 200, 200
    adaptive 1
    jitter
    point_at <-100, 0, 0>
  }
  light_source {
    <-10, -400, 30>
    color Red
    spotlight
    radius 12
    falloff 14
    tightness 10
    area_light <100, 0, 0>, <0, 0, 100>, 200, 200
    adaptive 1
    jitter
    point_at <-100, 0, 0>
  }
 
*/   

 #declare flag_HIDE_H_CTRL = false;

#declare text_voltage= object{

  difference {
   object {  Round_Box ( <-3.5, -0.5, 0.1>, <12, 2.5, 1>  , 0.125, 0) texture { T_Silver_1A } }   

 //   text {
 //     ttf "timrom.ttf" "4.0 V"  0.15, 0   
 //     pigment { BrightGold }
 //     finish { reflection .25 specular 1 phong 1 }
 //     translate -3*x
 //   }    
       object{ Bevelled_Text ("arial.ttf", 
         concat(str(Voltage_vs_PZC,0,1),"V vs PZC") ,// String
  20 ,      // Cuts
  10,       // BevelAngle
  0.045,    // BevelDepth
  4,        // Depth
  0.00,     // Offset
  0)        // 1 = "merge"
  texture{
   pigment{color rgb<1,0.70,0>}
   normal { bumps 0.5 scale 0.005}
   finish{ambient 0.1 diffuse 0.75 phong 1}
   } // end of texture
   scale<2.25,3,3>
   translate -3*x
 } // end of Bevelled_Text object 
 
  }
  
  // scale scale_it;
  // translate move_it; 

  
  }
  
  

#macro doAtom( R1, w, wb, type_geometry , color_atom , finish_atom )   
//#local  color_atom = Red;  
//#local finish_atom = finish { phong 1 };
   #switch (type_geometry)
     #case(0)  //BLOB
       #sphere{R1,w, wb      pigment { color color_atom } finish {finish_atom}   } 
       #break;  
     #case(2) // WIREFRAME WIREFRAME-DOT
       #break; // no atom
     #case(3) //  WIREFRAME-DOT
       #break; // no atom     
     #else               
     #else   
       #sphere{R1, w pigment { color color_atom } finish {finish_atom} } 
       #break;
   #end //switch
#end // macro   


#macro doBond (R1, R2, w, wb, type_geometry,  color_atom_1, finish_atom_1, color_atom_2, finish_atom_2  )   
  #local Rm=(R1+R2)/2;
  #local dr=(R2-R1);
  #local dist=VDist(R1, R2);    
   #switch (type_geometry)
     #case(0)     //=BLOB
       #cylinder(R1,R2,w,wb,tex) 
       #break;    
     #case(1)   //=CKP  
       #cylinder(R1,Rm,w,tex1)
       #cylinder(Rm,R2,w,tex2)
       #break;  
     #case(2)    //=WIREFRAME    
       //wireframe-solid    
       #break;
     #case(3)   //= WIREFRAME-DOT
       //wireframe-DOT
       #break;
       //   
     #else
        
   #end   
#end //macro  

 

#macro set_transmitance(z1,z2,zz)      
 #if(zz<=z1)
   #declare buffer_transmitance=0;
   #else
   #if (zz>z2)
     #declare buffer_transmitance=1;//off 
   #else
     #declare buffer_transmitance=(zz-z1)/(z2-z1);
   #end
   #end

#end //macro;
 
 
    

#macro render_molecule(Na, Nb,  type_represent, color_mixing_bond)     
#local ZZ_MIN_TRANMITANCE=-35;
#local ZZ_MAX_TRANSMITANCE=-3;
#switch (type_represent)       
#case(0) //blob     
  
 blob{  threshold blob_threshold     
 #local lc = 0;
 #while (lc < Na)    
    #local i = id_atoms[lc];  
    #if (selected_atom[i]) 
    #local imol = atom_in_which_molecule[i];    
    #local i_type_mol = i_type_molecule[imol]; 
    #local iw = wmt_array[i_type_mol];                              
    set_transmitance(ZZ_MIN_TRANMITANCE, ZZ_MAX_TRANSMITANCE, atom_xyz[i].z)
    #local local_transmit=buffer_transmitance;//ppt_Bond_Transparency[iw]      
#if (NO_TRANSPARENCY_CTRL)         
    #sphere{atom_xyz[i], atom_radius[i],atom_radius_B[i]   pigment { color atom_color[i] } finish {atom_finish[i]}   }   
#else    
    #sphere{atom_xyz[i], atom_radius[i],atom_radius_B[i]   pigment { color atom_color[i] transmit local_transmit } finish {atom_finish[i]}   }   
#end    
   #end 
   #local lc  = lc + 1;                                          
 #end //while   
 #local lc = 0; 
 #while (lc < Nb) 
   #local a = bonds[id_bonds[lc]];
   #local iat = a.x;  
   #local jat = a.y;// it is -1 because indexing starts from 0   
   #local imol = a.z;   
   #local i_type_mol = i_type_molecule[imol];
   #if(selected_atom[iat])
   #if(selected_atom[jat])    
     #local iw = wmt_array[i_type_mol];
     #local Rcyl = ppt_Cylinder_Radius[iw];
     #local Rcyl_b = ppt_Cylinder_Radius_Blob[iw]; 
     #local tt = -(atom_xyz[jat]-atom_xyz[iat]);   
         set_transmitance(ZZ_MIN_TRANMITANCE, ZZ_MAX_TRANSMITANCE, atom_xyz[iat].z)
             #local local_transmit=buffer_transmitance;//ppt_Bond_Transparency[iw]  
         set_transmitance(ZZ_MIN_TRANMITANCE, ZZ_MAX_TRANSMITANCE, atom_xyz[jat].z)             
             #local local_transmit_1=buffer_transmitance;//ppt_Bond_Transparency[iw]          
     #if (color_mixing_bond=0) // same to both 
         #if (wmt_array[i_type_mol]>=0)  
            #local this_bond_color =  ppt_Bond_Color[iw]; 
         #else                                                
            #local this_bond_color = a_default_bond_color;  
               //#debug concat ( str(i_type_mol,0,3)," wmt = ",str(wmt_array[i_type_mol],0,3), "\n"  )
         #end // if (wmt_array[i_type_mol] 
#if (NO_TRANSPARENCY_CTRL)                                                     
         #cylinder{atom_xyz[iat],atom_xyz[jat], Rcyl, Rcyl_b texture { pigment { color this_bond_color } finish { atom_finish[iat] } }   }    
#else 
         #cylinder{atom_xyz[iat],atom_xyz[jat], Rcyl, Rcyl_b texture { pigment { color this_bond_color transmit local_transmit } finish { atom_finish[iat] } }   }    
#end         
     #else 
     #if(color_mixing_bond=1)   // half half not mixed   
          #local tt2 = (atom_xyz[jat]+atom_xyz[iat])/2;  
#if (NO_TRANSPARENCY_CTRL)                                         
          #cylinder{atom_xyz[iat],tt2, Rcyl, Rcyl_b texture { pigment { color   atom_color[iat]  } } finish { atom_finish[iat] }    } 
          #cylinder{tt2, atom_xyz[jat],Rcyl, Rcyl_b texture { pigment { color   atom_color[jat]  } } finish { atom_finish[iat] }    }
#else
          #cylinder{atom_xyz[iat],tt2, Rcyl, Rcyl_b texture { pigment { color   atom_color[iat] transmit local_transmit } } finish { atom_finish[iat] }    } 
          #cylinder{tt2, atom_xyz[jat],Rcyl, Rcyl_b texture { pigment { color   atom_color[jat] transmit local_transmit_1 } } finish { atom_finish[iat] }    }
#end                
      #else 
      #if(color_mixing_bond=2)   
#if (NO_TRANSPARENCY_CTRL)                          
       #cylinder{atom_xyz[iat],atom_xyz[jat], Rcyl, Rcyl_b texture { pigment { gradient -tt color_map { [0.00  atom_color[iat] ] [1.00 atom_color[jat]] } scale  sqrt(vdot(tt,tt)) translate atom_xyz[iat] } finish { atom_finish[iat] } }   }
#else
       #cylinder{atom_xyz[iat],atom_xyz[jat], Rcyl, Rcyl_b texture { pigment { gradient -tt color_map { [0.00  atom_color[iat] transmit local_transmit ] [1.00 atom_color[jat] transmit local_transmit_1 ] } scale  sqrt(vdot(tt,tt)) translate atom_xyz[iat] } finish { atom_finish[iat] } }   }
#end            
      #end  // last if
      #end  // color_mixing_bond=1)
      #end  //color_mixing_bond=0

   #end  //jat 
   #end //iat 
 #local lc  = lc + 1;
 #end     
  }
#break;   

#case(1) //spheres 
  
union{  
 #local electrode_texture = texture { Chrome_Metal   }
 #local lc = 0;
 #while (lc < Na)                                
    #local i = id_atoms[lc];  
    #if (selected_atom[i]) 
    #local imol = atom_in_which_molecule[i];    
    #local i_type_mol = i_type_molecule[imol]; 
    #local iw = wmt_array[i_type_mol];  
    #local local_transmit=ppt_Bond_Transparency[iw];     
    set_transmitance(ZZ_MIN_TRANMITANCE, ZZ_MAX_TRANSMITANCE, atom_xyz[i].z)
    #local local_transmit=buffer_transmitance;//ppt_Bond_Transparency[iw]      
     
#if (NO_TRANSPARENCY_CTRL)  
    #if (ppt_names[iw]="ELECTRODE")  
        #sphere{atom_xyz[i], atom_radius[i]   texture { electrode_texture  } finish { reflection { .39975 } }     }
    #else 
    #sphere{atom_xyz[i], atom_radius[i]   pigment { color atom_color[i] } finish {atom_finish[i]}   }  
    #end                                   
    //doAtom(atom_xyz[i],  atom_radius[i], atom_radius_B[i] , type_represent, atom_color[i], atom_finish[i] ) 
#else   
    #if (ppt_names[iw]="ELECTRODE")  
        #sphere{atom_xyz[i], atom_radius[i]   texture { electrode_texture } finish { reflection { .39975  } }      }
    #else
    #sphere{atom_xyz[i], atom_radius[i]    pigment { color atom_color[i] transmit local_transmit } finish {atom_finish[i]}   } 
    #end                                    
#end     
    #end
   #local lc  = lc + 1;                                          
 #end //while  
 #local lc = 0; 
 #while (lc < Nb) 
   #local a = bonds[id_bonds[lc]];
   #local iat = a.x;  
   #local jat = a.y;  ;
   #local imol = a.z;   
   #local i_type_mol = i_type_molecule[imol]; 
   #local iw = wmt_array[i_type_mol];        
   #local tt = -(atom_xyz[jat]-atom_xyz[iat]);
   #if (selected_atom[iat])
   #if(selected_atom[jat])  
     #local Rcyl = ppt_Cylinder_Radius[iw];
     #local Rcyl_b = ppt_Cylinder_Radius_Blob[iw];   
     #local tt = -(atom_xyz[jat]-atom_xyz[iat]);   
     #local local_transmit=ppt_Bond_Transparency[iw];   
     
   
       
         set_transmitance(ZZ_MIN_TRANMITANCE, ZZ_MAX_TRANSMITANCE, atom_xyz[iat].z)
             #local local_transmit=buffer_transmitance;//ppt_Bond_Transparency[iw]  
         set_transmitance(ZZ_MIN_TRANMITANCE, ZZ_MAX_TRANSMITANCE, atom_xyz[jat].z)             
             #local local_transmit_1=buffer_transmitance;//ppt_Bond_Transparency[iw]          

 
     
     
     #if (color_mixing_bond=0) // same to both   
         #if (wmt_array[i_type_mol]>=0)  
            #local this_bond_color =  ppt_Bond_Color[iw]; 
         #else                                                
            #local this_bond_color = a_default_bond_color;  
               //#debug concat ( str(i_type_mol,0,3)," wmt = ",str(wmt_array[i_type_mol],0,3), "\n"  )
         #end // if (wmt_array[i_type_mol]         
#if (NO_TRANSPARENCY_CTRL)        
      #cylinder{atom_xyz[iat],atom_xyz[jat], Rcyl  texture { pigment { color this_bond_color  } finish { atom_finish[iat] } }   }  
#else 
      #cylinder{atom_xyz[iat],atom_xyz[jat], Rcyl  texture { pigment { color this_bond_color transmit local_transmit } finish { atom_finish[iat] } }   }  
#end        
     #else 
      #if(color_mixing_bond=1)   // half half not mixed   
       #local tt2 = (atom_xyz[jat]+atom_xyz[iat])/2;  
#if (NO_TRANSPARENCY_CTRL)                    
       #cylinder{atom_xyz[iat],tt2, Rcyl  texture { pigment { color   atom_color[iat]  } } finish { atom_finish[iat] }    } 
       #cylinder{tt2, atom_xyz[jat],Rcyl  texture { pigment { color   atom_color[jat]  } } finish { atom_finish[iat] }    } 
#else 
       #cylinder{atom_xyz[iat],tt2, Rcyl  texture { pigment { color   atom_color[iat]  transmit local_transmit } } finish { atom_finish[iat] }    } 
       #cylinder{tt2, atom_xyz[jat],Rcyl  texture { pigment { color   atom_color[jat]  transmit local_transmit } } finish { atom_finish[iat] }    } 
#end            
      #else 
       #if(color_mixing_bond=2)   
#if (NO_TRANSPARENCY_CTRL)        
       #cylinder{atom_xyz[iat],atom_xyz[jat], Rcyl  texture { pigment { gradient -tt color_map { [0.00  atom_color[iat] ] [1.00 atom_color[jat] ] } scale  sqrt(vdot(tt,tt)) translate atom_xyz[iat] } finish { atom_finish[iat] } }   }  
#else
       #cylinder{atom_xyz[iat],atom_xyz[jat], Rcyl  texture { pigment { gradient -tt color_map { [0.00  atom_color[iat] transmit local_transmit ] [1.00 atom_color[jat] transmit local_transmit ] } scale  sqrt(vdot(tt,tt)) translate atom_xyz[iat] } finish { atom_finish[iat] } }   }  
#end
       #end  // last if
      #end  // color_mixing_bond=1)
     #end  //color_mixing_bond=0
   #end //jat
   #end //iat     
 #local lc  = lc + 1;
 #end         
 }     
 
#break;  

#case(2) //=WIREFRAME 
     
 #local local_transmit=0.75;
 #local lc = 0; 
 #while (lc < Nb) 
   #local a = bonds[id_bonds[lc]];
   #local iat = a.x;  
   #local jat = a.y;      
   #local imol = a.z;     
   #local i_type_mol = i_type_molecule[imol];   
   #local iw = wmt_array[i_type_mol];  
   #local tt = -(atom_xyz[jat]-atom_xyz[iat]);
   #if (selected_atom[iat])
   #if(selected_atom[jat])    
     #local Rcyl = ppt_Wireframe_Widths[iw];
 //    #local Rcyl_b = ppt_Cylinder_Radius_Blob[iw];      
     #local tt = -(atom_xyz[jat]-atom_xyz[iat]);   
     #local local_transmit=ppt_Wireframe_Transparency[iw];
     #if (color_mixing_bond=0) // same to both   
         #if (wmt_array[i_type_mol]>=0)  
            #local this_bond_color =  ppt_Bond_Color[iw]; 
         #else                                                
            #local this_bond_color = a_default_bond_color;  
               //#debug concat ( str(i_type_mol,0,3)," wmt = ",str(wmt_array[i_type_mol],0,3), "\n"  )
         #end // if (wmt_array[i_type_mol]      
#if (NO_TRANSPARENCY_CTRL) 
      #object{Round_Cylinder(atom_xyz[iat],atom_xyz[jat], Rcyl,Rcyl,0)  texture { pigment { color this_bond_color  } finish { atom_finish[iat] } }   }  
#else           
      #object{Round_Cylinder(atom_xyz[iat],atom_xyz[jat], Rcyl,Rcyl,0)  texture { pigment { color this_bond_color transmit local_transmit } finish { atom_finish[iat] } }   }    
#end
     #else 
      #if(color_mixing_bond=1)   // half half not mixed   
       #local tt2 = (atom_xyz[jat]+atom_xyz[iat])/2;   
#if (NO_TRANSPARENCY_CTRL)
       #object{Round_Cylinder(atom_xyz[iat],tt2, Rcyl,Rcyl,0)  texture { pigment { color   atom_color[iat]  }  finish { atom_finish[iat] }    } }
       #object{Round_Cylinder(tt2, atom_xyz[jat],Rcyl,Rcyl,0)   texture { pigment { color   atom_color[jat] } finish { atom_finish[iat] }    } }
#else           
       #object{Round_Cylinder(atom_xyz[iat],tt2, Rcyl,Rcyl,0)  texture { pigment { color   atom_color[iat] transmit local_transmit }  finish { atom_finish[iat] }    } }
       #object{Round_Cylinder(tt2, atom_xyz[jat],Rcyl,Rcyl,0)   texture { pigment { color   atom_color[jat]  transmit local_transmit} finish { atom_finish[iat] }    } } 
#end           
      #else 
       #if(color_mixing_bond=2)      
#if (NO_TRANSPARENCY_CTRL)       
       #object{Round_Cylinder(atom_xyz[iat],atom_xyz[jat], Rcyl,Rcyl,0)   texture { pigment { gradient -tt color_map {[ 0.00  atom_color[iat] ] [1.00 atom_color[jat] ] } scale  sqrt(vdot(tt,tt)) translate atom_xyz[iat] } finish { atom_finish[iat] } }   }  
#else
       #object{Round_Cylinder(atom_xyz[iat],atom_xyz[jat], Rcyl,Rcyl,0)   texture { pigment { gradient -tt color_map {[ 0.00  atom_color[iat] transmit local_transmit] [1.00 atom_color[jat] transmit local_transmit] } scale  sqrt(vdot(tt,tt)) translate atom_xyz[iat] } finish { atom_finish[iat] } }   }  
#end
       #end  // last if
      #end  // color_mixing_bond=1)
     #end  //color_mixing_bond=0
   #end //jat
   #end //iat     
 #local lc  = lc + 1;
 #end  
 
#else 
#end // (type_geom=1)(sphere)  

#end //macro render_molecule(Na, Nb, type_goem, ...)    
 
 

 


 

/////////////////////////////////////////  


///////////////////////////  


#macro set_wm_ta_array()

///wmt
#local i_type_mol=0;   
#while (i_type_mol<N_type_molecules)
#local i_case_select=0;  
#declare wmt_array[i_type_mol]=-1;
#while (i_case_select<N_predefined_types) 
//#debug concat ( ppt_names[i_case_select], mol_type_render_style[i_type_mol], "\n"  )
    #if (ppt_names[i_case_select]=mol_type_render_style[i_type_mol])   
       #declare wmt_array[i_type_mol]=i_case_select;  
       #debug concat ("wmt_array=",  str(wmt_array[i_type_mol], 0, 3), " for mol=",ppt_names[i_case_select],"\n"   ) 
   #end
#local i_case_select=i_case_select+1; 
#end // i_case_select<N_predefined_types
#local i_type_mol=i_type_mol+1;   
#end  

#declare N_type_mols_selected_for_render = 0;
#local i_type_mol=0;   
#while (i_type_mol<N_type_molecules)  
  #if (wmt_array[i_type_mol]>-1)
   #declare N_type_mols_selected_for_render = N_type_mols_selected_for_render+1;
  #end      
#debug concat (str(i_type_mol, 0, 3)," >",  str(wmt_array[i_type_mol], 0, 3), "  ", mol_type_name[i_type_mol]," <---> ", mol_type_render_style[i_type_mol],  "\n"   )   
#local i_type_mol=i_type_mol+1;      
#end
#debug concat ("N_type_mols_selected_for_render=",  str(N_type_mols_selected_for_render, 0, 3), "\n"   ) 
 
///wma 

  #local i = 0;
  #while(i<Natoms)     
  #local i_type = i_type_atom[i];   
 // #debug concat ("i=",  str(i, 0, 3), "\n"   ) 
      #declare wma_array[i]=-1;
      #local j=0;
      #while(j<N_predefined_atoms)
          #if (atom_type_symbol[i_type]=ppa_names[j])  
             #declare wma_array[i] = j ;
           //  #break;
          #end
      #local j = j + 1;
      #end
  #local i = i + 1;       
  #end //while         
  
 #local i = 0;
 #while(i<Natoms)    
   #if (  wma_array[i]<0) 
      #declare wma_array[i]= N_predefined_atoms-1;       
   #end //if 
 //#debug concat (str(i, 0, 3)," >",  str(wma_array[i], 0, 3), "\n"   ) 
 #local i = i + 1;      
 #end   //while

#end //macro

//////////////////////////////                           get_sizes_selections    

  

#macro set_default_atom_selector()
     #local i = 0;  
     #declare N_atoms_selected = 0;
     #while (i<Natoms)
          #local i_type=i_type_atom[i];
          #local imol = atom_in_which_molecule[i];  
          #local i_type_mol = i_type_molecule[imol]; 
          #local l= selected_type_molecule[i_type_mol]; 
          #if (flag_HIDE_DUMMY_CTRL)  
              #local l=(l&(!is_dummy[i])); 
          #end    
          #if (flag_HIDE_H_CTRL) 
              #local l=(l&(!(atom_type_symbol[i_type]="H")));   
          #end    
          #if ( l )
             #declare selected_atom[i]=true; 
             #declare N_atoms_selected =  N_atoms_selected + 1;
          #else
             #declare selected_atom[i]=false;
          #end//if      
     #local i = i + 1;     
     #end //while
 #debug concat ("Total Atoms=",str(Natoms, 0, 3)," >selected atoms=",  str(N_atoms_selected, 0, 3), "\n"   )         
#end //macro
////////////////////////////
  

#macro set_default_bond_selector()
     #local i = 0;  
     #declare N_bonds_selected = 0;
     #while (i<Nbonds)
          #local ib=bonds[i];
          #local iat=ib.x;
          #local jat=ib.y;
          #local imol = ib.z;  
          #local i_type_mol = i_type_molecule[imol];
          #if (selected_atom[iat] & selected_atom[jat] & selected_type_molecule[i_type_mol] )
             #declare selected_bond[i]=true; 
             #declare N_bonds_selected =  N_bonds_selected +1;
          #else
             #declare  selected_bond[i]=false;
          #end//if      
      #local i = i + 1;         
     #end //while
 #debug concat ("Total Bonds=",str(Nbonds, 0, 3)," >selected bonds=",  str(N_bonds_selected, 0, 3), "\n"   )         
#end //macro

///////////////////////////////////
                                                         
#macro set_initial_selections() 
set_wm_ta_array()             
set_default_atom_selector()
set_default_bond_selector()
#local i_case_select=0; 
#while (i_case_select<N_predefined_types)
#declare N_mols_selected_per_case[i_case_select]=0;  
 #local i_mol=0;
 #while (i_mol<Nmols)  
  #local i_type_mol=i_type_molecule[i_mol]; 
   #if (i_case_select=wmt_array[i_type_mol])
     #declare N_mols_selected_per_case[i_case_select]=N_mols_selected_per_case[i_case_select]+1;   
   #end // i_case_select=i_type_mol      
 #local i_mol=i_mol+1;    
 #end //  i_mol<Nmols         
 #debug concat (str(i_case_select, 0, 3)," >",  str(N_mols_selected_per_case[i_case_select], 0, 3), "<-->",ppt_names[i_case_select], "\n"   ) 
#local i_case_select = i_case_select + 1;     
#end //  i_case_select<N_predefined_types
 

// DISCONECT H-H WATER   

  #local i_mol = 0;   
  #local counts_H_H_disconeted=0;
  #while (i_mol<Nmols)    

  #if ((start_group_bonds[i_mol]>=0) & (end_group_bonds[i_mol]>=0))
 // #if (selected_type_molecule[i_type_molecule[i_mol]])
     #local i0b=0;   
     #local i=start_group_bonds[i_mol];
     #while (i<=end_group_bonds[i_mol])  
       #local ib=bonds[i];
       #if (ib.z=i_mol)     
              #local i_type_m = i_type_molecule[i_mol];
              #local iw = wmt_array[i_type_m];     // wmt was set a bit up in this subrotine
                #if (iw>=0)
                   #local lll= (ppt_names[iw]="H2O"); 
                #else
                   #local lll = false;   
                #end
              #if (mol_type_name[i_type_m]="H2O" | lll )   
                  #local iat = i_type_atom[ib.x];
                  #local jat = i_type_atom[ib.y]; 
                  #if(atom_type_symbol[iat]=atom_type_symbol[jat])       
                     #declare selected_bond[i]=false;  
                     #local counts_H_H_disconeted=counts_H_H_disconeted+1;
                  #end
              #end // #if (mol_type_name(i_type_m)="H2O" | lll ) 
       #end //#if (ib.z=i_mol)         
     #local i=i+1;   
     #end  // while (i<=end_group_bonds[i_mol]) 
  #end // #if ((start_group_bonds[i_mol]>=0) & (end_group_bonds[i_mol]>=0))
 #local i_mol = i_mol + 1   ;
#end //final while water HH disconect

 #debug concat ("Total H-H Water Bonds Disconected=",str(counts_H_H_disconeted, 0, 3),"\n"   )         
 

// \DISCONECT H-H WATER 
   
 
 #local i_mol=0;
 #while (i_mol<Nmols)  
      #local i0=0;
      #local i=start_group[i_mol];
      #while (i<=end_group[i_mol]) // the actual atom  
         #if (selected_atom[i])
             #local i0=i0+1;   
         #end // (selected_atom(i))  
      #local i=i+1;      
      #end   //(i<=end_group(i_mol) 
      #declare N_atoms_selected_per_mol[i_mol]=i0;   
 //#debug concat (str(i, 0, 3)," >",  str(i0, 0, 3), "\n"   )                                
 #local i_mol=i_mol+1;                                        
 #end //i_mol<Nmols       
  
  #local i_mol = 0;
  #while (i_mol<Nmols) 
  #declare N_bonds_selected_per_mol[i_mol]=0;
  #if ((start_group_bonds[i_mol]>=0) & (end_group_bonds[i_mol]>=0))
 // #if (selected_type_molecule[i_type_molecule[i_mol]])
     #local i0b=0;   
     #local i=start_group_bonds[i_mol];
     #while (i<=end_group_bonds[i_mol])  
       #local ib=bonds[i];
       #if (ib.z=i_mol)
       #if (selected_bond[i]) 
          #local i0b=i0b+1;   
       #end   
       #end //if        
     #local i=i+1;   
     #end  // #local i0b=0;
    #declare N_bonds_selected_per_mol[i_mol] =i0b; 
    // #debug concat (str(i_mol, 0, 3)," >",  str(N_bonds_selected_per_mol[i_mol], 0, 3), "\n"   )                                       
  
  #end //start end groupbonds +
  #local i_mol=i_mol+1;      
  #end  //(i_mol<Nmols)
  
      
#end //macro   get_sizes_selections 


////////////////////////


#declare atom_color=array[Natoms];
#macro set_atom_color()
//atom_color = pp_ta_Sphere_Color [i_case_select][i_case_atom_select]   
#local i = 0;
#while(i<Natoms)
  #local imol=atom_in_which_molecule[i];
  #local i_type_mol = i_type_molecule[imol];
  #local i_case_select = wmt_array[i_type_mol];
  #local j = wma_array[i]; 
  #if (i_case_select>=0)
   #declare atom_color[i]=pp_ta_Sphere_Color[i_case_select][j] ;
  #else 
   #declare atom_color[i]=color Black;//pp_ta_Sphere_Color[N_predefined_types][j] 
  #end 
 // #debug concat (str(i, 0, 3)," >",  str(atom_color[i]),  "\n"   )      
#local i = i + 1;  
#end //while(i<Natoms)
#end //macro set_atom_color  

#declare atom_radius=array[Natoms];
#macro set_atom_radius()
//atom_color = pp_ta_Sphere_Color [i_case_select][i_case_atom_select]   
#local i = 0;
#while(i<Natoms)
  #local imol=atom_in_which_molecule[i];
  #local i_type_mol = i_type_molecule[imol];
  #local i_case_select = wmt_array[i_type_mol];
  #local j = wma_array[i]; 
  #if (i_case_select>=0)
   #declare atom_radius[i]=pp_ta_Sphere_Radius[i_case_select][j] ;
  #else 
   #declare atom_radius[i]=0.2;//pp_ta_Sphere_Color[N_predefined_types][j] 
  #end 
 // #debug concat (str(i, 0, 3)," >",  str(atom_color[i]),  "\n"   )      
#local i = i + 1;  
#end //while(i<Natoms)
#end //macro set_atom_color 

#declare atom_radius_B=array[Natoms];
#macro set_atom_radius_B()
//atom_color = pp_ta_Sphere_Color [i_case_select][i_case_atom_select]   
#local i = 0;
#while(i<Natoms)
  #local imol=atom_in_which_molecule[i];
  #local i_type_mol = i_type_molecule[imol];
  #local i_case_select = wmt_array[i_type_mol];
  #local j = wma_array[i]; 
  #if (i_case_select>=0)
   #declare atom_radius_B[i]=pp_ta_Sphere_Radius_Blob[i_case_select][j] ;
  #else 
   #declare atom_radius_B[i]=0.03;//pp_ta_Sphere_Color[N_predefined_types][j] 
  #end 
 // #debug concat (str(i, 0, 3)," >",  str(atom_color[i]),  "\n"   )      
#local i = i + 1;  
#end //while(i<Natoms)
#end //macro set_atom_color 


#declare atom_finish=array[Natoms];
#macro set_atom_finish()
//atom_color = pp_ta_Sphere_Color [i_case_select][i_case_atom_select]   
#local i = 0;
#while(i<Natoms)
  #local imol=atom_in_which_molecule[i];
  #local i_type_mol = i_type_molecule[imol];
  #local i_case_select = wmt_array[i_type_mol];
  #local j = wma_array[i]; 
  #if (i_case_select>=0)
   #declare atom_finish[i]=ppt_Finishes_Atoms[i_case_select] ;
  #else 
   #declare atom_finish[i]=ppa_Finishes_Atoms[j] ;
  #end     
#local i = i + 1;  
#end //while(i<Natoms)
#end //macro set_atom_color  

#macro re_center()
    #local i = 0;    
    #local XX_min=9.9E99;
    #local YY_min=9.9E99; 
    #local ZZ_min=9.9E99;  
    #local XX_max=-9.9E99;
    #local YY_max=-9.9E99; 
    #local ZZ_max=-9.9E99;    
    #while(i<Natoms)    
    #if(selected_atom[i])
       #local r = atom_xyz[i];
       #if (r.x<XX_min) 
          #local XX_min=r.x;
       #end  
       #if (r.y<YY_min) 
          #local YY_min=r.y;
       #end 
       #if (r.z<ZZ_min) 
          #local ZZ_min=r.z;
       #end 
       #if (r.x>XX_max) 
          #local XX_max=r.x;
       #end  
       #if (r.y>YY_max) 
          #local YY_max=r.y;
       #end 
       #if (r.z>ZZ_max) 
          #local ZZ_max=r.z;
       #end              
    #end //if selected   
    #local i = i + 1;                  
    #end   //while
  #debug concat ("Xmin max=",str(XX_min, 0, 3)," >",  str(XX_max, 0, 3),  "\n"   )       
  #debug concat ("Ymin max=",str(YY_min, 0, 3)," >",  str(YY_max, 0, 3),  "\n"   ) 
  #debug concat ("Zmin max=",str(ZZ_min, 0, 3)," >",  str(ZZ_max, 0, 3),  "\n"   ) 
    #local i = 0;    
    #while(i<Natoms) 
          #local r = atom_xyz[i];
          #local rx=r.x-(XX_min+XX_max)/2;  
          #local ry=r.y-(YY_min+YY_max)/2; 
          #local rz=r.z-(ZZ_min+ZZ_max)/2; 
          #declare atom_xyz[i]=<rx,ry,rz>;        
    #local i = i + 1;        
    #end //if selected   
    #local i = 0;    
    #while(i<Nmols) 
          #local r = mol_xyz[i];
          #local rx=r.x-(XX_min+XX_max)/2;  
          #local ry=r.y-(YY_min+YY_max)/2; 
          #local rz=r.z-(ZZ_min+ZZ_max)/2; 
          #declare mol_xyz[i]=<rx,ry,rz>;        
    #local i = i + 1;        
    #end //if selected   
   
 #end//macro re_center       

#macro  hide_selection_by_CM_ZZ(z_select_MIN, z_select_MAX) 
#local i_mol = 0;   
#while (i_mol<Nmols)   
     #local tt=mol_xyz[i_mol];
     #if (tt.z>z_select_MIN & tt.z<z_select_MAX)       
         #local i=start_group[i_mol];
         #while (i<=end_group[i_mol])
             #declare selected_atom[i]=false;
         #local i = i +1;      
         #end
         #local i=start_group_bonds[i_mol];  
         #if (i>=0)
           #while (i<=end_group_bonds[i_mol])
             #declare selected_bond[i]=false;
           #local i = i +1;  
           #end    
         #else    
             //#declare selected_bond[i]=false;
         #end
     #else
     #end
#local i_mol=i_mol+1;    
#end
#end //macro      

//#macro  set_selection()
   /*
select_atoms_by_mol_type_number
select_atoms_by_atom_type_number
select_atoms_by_designation_number 
select_atoms_by_mol_type_name
select_atoms_by_atom_type_name
select_atoms_by_designation_name 
select_atoms_by_atom_type_symbol
select_atoms_by_atom_number  
select_atoms_by_mol_CM_in_xyz
select_atoms_by_mol_CM_in_spherical_R_from_R0  
select_atoms_by_mol_if_any_atom_in_xyz
select_atoms_by_mol_if_any_atom_in_spherical_R_from_R0


 */

#macro  periodic_boundary()     

#declare reference_atom = <0.7115000,1.232354,-42.43686> ;
                         
    #local i=0;
    #while (i<Natoms) 
              #local tt=atom_xyz[i];   
              #local a = tt.x/boxa[1];
              #local tx=tt.x-( int(2*a) - int(a) ) * boxa[1];      
              #local a = tt.y/boxa[2];
              #local ty=tt.y-( int(2*a) - int(a) ) * boxa[2];    
              #local tz=tt.z;
              #declare atom_xyz[i]=<tx,ty,tz> ;
    #local i=i+1;
    #end
#end //macro periodic boundary         



//#end //macro   set_selection

//set_selection()
set_initial_selections()   
hide_selection_by_CM_ZZ(0,1000)  
set_atom_color() 
set_atom_finish()   
set_atom_radius()
set_atom_radius_B()   
//periodic_boundary() 
//re_center()

union{ 

#local i_case_select = 0;
#while (i_case_select<N_predefined_types)  
 #local i_mol_i=0;
 #while (i_mol_i<Nmols)   
  //#debug concat ("START LOOP i_mol=", str(i_mol_i,0,3))
  #local i_type_mol=i_type_molecule[i_mol_i];
  #if (i_case_select=i_type_mol)    // We are in the type molecule that we want   
  #local i0a=0;
  #local i0b=0;        
  
      #local isize=N_atoms_selected_per_mol[i_mol_i];  
      #if (isize>0)    
      #local i=start_group[i_mol_i];       
      #local id_atoms=array[isize];
      #while (i<=end_group[i_mol_i]) // the actual atom  
         #if (selected_atom[i])  
          #local id_atoms[i0a]=i; 
          #local i0a=i0a+1;   
         #end // (selected_atom(i))     
      #local i = i  + 1;
      #end   //(i<=end_group(i_mol)  
      #end // isize>0                               
   

     #if ((start_group_bonds[i_mol_i]>=0) & (end_group_bonds[i_mol_i]>=0))
     #local i_size = N_bonds_selected_per_mol[i_mol_i]; 
     #if(i_size>0)
     #local id_bonds=array[i_size];  
     #local i=start_group_bonds[i_mol_i];
     #while (i<=end_group_bonds[i_mol_i])  
       #if (selected_bond[i]) 
       #local ib=bonds[i];
       #if (ib.z=i_mol_i) 
         
        #local tt=atom_xyz[ib.x]-atom_xyz[ib.y];
          #local dist = sqrt(tt.x*tt.x+tt.y*tt.y+tt.z*tt.z);
          #if (dist<3.0)
       
          #local id_bonds[i0b]=i; 
          #local i0b=i0b+1;    
          
          #end
              
       #end  //if
       #end  //if      
       #local i=i+1; 
       #end //while 
     #end //  (i_size>0)         
     #end  // #if ((start_group_bonds[i_mol]>=0) & (end_group_bonds[i_mol]>=0))

     //#debug concat (str(i_mol_i, 0, 3)," >",  str(N_bonds_selected_per_mol[i_mol_i], 0, 3), "\n"   )                                       
  

 
 
 
 
   #if (i0a>0)
   #debug concat ("i_mol_i=",str(i_mol_i, 0, 3)," > i0a=",  str(i0a, 0, 3),  "i0b=", str(i0b, 0, 3),"\n"   ) 
   #end
    
#if (i0a>0)   
#local iw=wmt_array[i_type_molecule[i_mol_i]];      
    #if (i0b>0) 
       #local mixing_color_bond=ppt_color_mixing_bond[iw]; 
       #local style_bond_connect = ppt_style_bond[iw]; 
    #else
       #local mixing_color_bond=0;   
       #local style_bond_connect = 1;//only spheres
    #end
 render_molecule(i0a, i0b, style_bond_connect, mixing_color_bond)   
#end


 
  #end //#if (i_case_select=i_type_mol)s
  #local i_mol_i=i_mol_i+1;      
  //#debug concat ("Finished the loop  i_mol=", str(i_mol_i,0,3))                                   
 #end //i_mol<Nmols   
#local i_case_select = i_case_select + 1;
#end //i_case_select<N_predefined_types 


object { text_voltage  scale 0.6  rotate <-90,270,0> translate <-12.5, -23.4,-34> rotate <10,0,0>}

translate <00,0,20>       
rotate <-12,90,0>      
scale 2.4
translate <-0,0,0> 
scale 1.2              
//rotate <40,1,0>  
//rotate <40,0,0>    
}            








