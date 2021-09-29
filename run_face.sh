#python face_eyebrow_detetor.py origin_image_file shrink_image_file ouput_file
script_dir=/Users/taoxianming/Documents/face2DExtract/eyebrow/quantification_eyebrow/script

#######
#pathSum=/Users/taoxianming/Documents/face2DExtract/eyebrow/quantification_eyebrow/example3
#origin_image_file=${pathSum}/origin_figure
#shrink_image_file=${pathSum}/shrink_figure
#ouput_file=${pathSum}/result

#resize
#python ${script_dir}/face_resize.py ${origin_image_file} ${shrink_image_file}

#face_eyebrow_detector
#python ${script_dir}/face_eyebrow_detector.py ${origin_image_file} ${shrink_image_file} ${ouput_file}

#eyebrow_quantification
#left eyebrow
#eyebrow_image_file=${pathSum}/result/left_eyebrow
#python ${script_dir}/eyebrow_quantification.py ${eyebrow_image_file} ${ouput_file}/left_result

path=/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/XJW_gongan/male/test
python ${script_dir}/eyebrow_quantification2.py ${path}/eyebrow ${path}/eyebrow_result

#right eyebrow
#eyebrow_image_file=${pathSum}/result/right_eyebrow
#python ${script_dir}/eyebrow_quantification.py ${eyebrow_image_file} ${ouput_file}/right_result

#calculate eye distance
#landmark_dir=${pathSum}/result/landmark
#python ${script_dir}/cal_distance_landmark.py ${landmark_dir}



######eyebrow improve by tao
script_dir=/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/script
#path=/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/XJW_gongan/both
path=/Users/taoxianming/Documents/face2DExtract/eyebrow_tao/RS_pic_loc
python ${script_dir}/eyebrow_image_extraction.py ${path}/eyebrow ${path}/eyebrow_image_extraction


